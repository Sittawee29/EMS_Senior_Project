from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
import threading
import json
import math
import paho.mqtt.client as mqtt
from uvicorn import run
import sqlite3
import time
from datetime import datetime
import io
import csv
import redis  # <--- [NEW] เพิ่ม Library Redis

# ==========================================
# 1. Config & Setup
# ==========================================
MQTT_BROKER = "iicloud.tplinkdns.com"
MQTT_PORT = 7036
MQTT_USER = "mqtt_user"
MQTT_PASS = "ADMINktt5120@"
DB_NAME = "energy_data.db"

# [NEW] Redis Configuration
REDIS_HOST = "localhost"
REDIS_PORT = 6379
REDIS_DB = 0

# เชื่อมต่อ Redis
try:
    redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
    redis_client.ping()
    print("✅ Connected to Redis (Hot Data Layer)")
except Exception as e:
    print(f"❌ Failed to connect to Redis: {e}")

DEFAULT_KEYS = [
    # --- METER ---
    "METER_V1", "METER_V2", "METER_V3",
    "METER_I1", "METER_I2", "METER_I3",
    "METER_KW", "METER_Total_KWH",
    "METER_Export_KVARH", "METER_Export_KWH", "METER_Import_KVARH", "METER_Import_KWH",
    "METER_Total_KVARH", "METER_Hz", "METER_PF",
    "METER_I_Total", "METER_KVAR", "METER_KW_Invert", "METER_Grid_Power_KW",

    # --- EMS ---
    "PV_Total_Energy", "PV_Daily_Energy", "Load_Total_Energy", "Load_Daily_Energy",
    "GRID_Total_Import_Energy", "GRID_Daily_Import_Energy", "GRID_Total_Export_Energy", "GRID_Daily_Export_Energy",
    "BESS_Daily_Charge_Energy", "BESS_Daily_Discharge_Energy", "EMS_CO2_Equivalent",
    "EMS_EnergyProducedFromPV_Daily", "EMS_EnergyFeedToGrid_Daily", "EMS_EnergyConsumption_Daily",
    "EMS_EnergyFeedFromGrid_Daily", "EMS_SolarPower_kW", "EMS_LoadPower_kW",

    # --- BESS ---
    "BESS_SOC", "BESS_SOH", "BESS_V", "BESS_I", "BESS_KW", "BESS_Temperature",
    "BESS_Total_Discharge", "BESS_Total_Charge", "BESS_SOC_MAX", "BESS_SOC_MIN",
    "BESS_Power_KW_Invert", "BESS_Manual_Power_Setpoint", "BESS_PID_CycleTime",
    "BESS_PID_Td", "BESS_PID_Ti", "BESS_PID_Gain", "BESS_Temp_Ambient",
    "BESS_Alarm", "BESS_Fault", "BESS_Communication_Fault",

    # --- PV1 ---
    "PV1_Grid_Power_KW", "PV1_Load_Power_KW", "PV1_Daily_Energy_Power_KWh", "PV1_Total_Energy_Power_KWh",
    "PV1_Power_Factor", "PV1_Reactive_Power_KVar", "PV1_Active_Power_KW", "PV1_Fault", "PV1_Communication_Fault",

    # --- PV2 ---
    "PV2_Energy_Daily_kW", "PV2_LifeTimeEnergyProduction_kWh_Start", "PV2_LifeTimeEnergyProduction_kWh",
    "PV2_ReactivePower_kW", "PV2_ApparentPower_kW", "PV2_Active_Power_kW", "PV2_LifeTimeEnergyProduction",
    "PV2_PowerFactor_Percen", "PV2_ReactivePower", "PV2_ApparentPower", "PV2_Power", "PV2_Communication_Fault",

    # --- PV3 ---
    "PV3_Total_Power_Yields_Real", "PV3_Total_Apparent_Power_kW", "PV3_Total_Reactive_Power_kW", "PV3_Active_Power_kW",
    "PV3_Total_Reactive_Power", "PV3_Total_Active_Power", "PV3_Total_Apparent_Power", "PV3_Total_Power_Yields",
    "PV3_Daily_Power_Yields", "PV3_Nominal_Active_Power", "PV3_Communication_Fault",

    # --- PV4 ---
    "PV4_Total_Power_Yields_Real", "PV4_Total_Apparent_Power_kW", "PV4_Total_Reactive_Power_kW", "PV4_Active_Power_kW",
    "PV4_Total_Reactive_Power", "PV4_Total_Active_Power", "PV4_Total_Apparent_Power", "PV4_Total_Power_Yields",
    "PV4_Daily_Power_Yields", "PV4_Nominal_Active_Power", "PV4_Communication_Fault"
]

# ส่วน Initialize (ห้ามลืมใส่ส่วนนี้ต่อท้าย list)
print("⏳ Initializing Redis keys...")
pipe = redis_client.pipeline()
for key in DEFAULT_KEYS:
    pipe.setnx(key, 0.0) # สร้าง Key เฉพาะถ้ายังไม่มี
pipe.execute()
print("✅ Redis keys initialized complete.")

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS meter_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME, 
            v1 REAL, v2 REAL, v3 REAL,
            i1 REAL, i2 REAL, i3 REAL,
            kw_total REAL,
            kwh_total REAL
        )
    ''')
    conn.commit()
    conn.close()
    print("✅ Database Initialized (Cold Data Layer)")

init_db()

# รายชื่อ Keys ที่เราสนใจ (สำหรับดึงจาก Redis ไปลง DB)
INTERESTED_KEYS = [
    "METER_V1", "METER_V2", "METER_V3",
    "METER_I1", "METER_I2", "METER_I3",
    "METER_KW", "METER_Total_KWH"
]

app = FastAPI()
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

# ==========================================
# 2. MQTT Logic (Write to Hot Data)
# ==========================================
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT Broker!")
    topics = ["EMS/#", "BESS/#", "METER/#", "PV1/#", "bdmsry/meter"]
    for t in topics: client.subscribe(t)

def on_message(client, userdata, msg):
    try:
        topic = msg.topic
        payload = msg.payload.decode("utf-8")
        
        # [DEBUG]
        #print(f"📨 RECEIVED: {topic} -> {payload}") 

        updates = {}

        # กรณี 1: JSON Payload
        if "{" in payload and "}" in payload:
            try:
                data_json = json.loads(payload)
                
                # 1.1 JSON Mapping (Manual)
                if "v1" in data_json: updates["METER_V1"] = data_json["v1"]
                if "v2" in data_json: updates["METER_V2"] = data_json["v2"]
                if "v3" in data_json: updates["METER_V3"] = data_json["v3"]
                if "i1" in data_json: updates["METER_I1"] = data_json["i1"]
                if "i2" in data_json: updates["METER_I2"] = data_json["i2"]
                if "i3" in data_json: updates["METER_I3"] = data_json["i3"]
                if "kwhtotal" in data_json: updates["METER_Total_KWH"] = data_json["kwhtotal"]
                if "p" in data_json: updates["METER_KW"] = data_json["p"]

                # 1.2 JSON Auto-Map
                for key, val in data_json.items():
                    if isinstance(val, (int, float)):
                        updates[key] = val
                        
            except json.JSONDecodeError:
                print(f"❌ JSON Error: {payload}")

        else: 
            try:
                value = float(payload)
                if math.isnan(value) or math.isinf(value): value = 0.0
                
                parts = topic.split("/")
                suffix = parts[-1]   # เช่น PV_Total_Energy, SOC
                prefix = parts[0]    # เช่น EMS, BESS
                if suffix in DEFAULT_KEYS:
                     key_name = suffix 
                else:
                     key_name = f"{prefix}_{suffix}"

                updates[key_name] = value
                
            except ValueError:
                pass 

        # [Final Step] บันทึกลง Redis
        if updates:
            pipe = redis_client.pipeline()
            for k, v in updates.items():
                pipe.set(k, v) 
            pipe.execute()

    except Exception as e: 
        print(f"MQTT Error: {e}")

# ==========================================
# 3. Background Tasks (Sync Hot -> Cold)
# ==========================================
def db_saver_loop():
    # Loop นี้คือตัวเชื่อมระหว่าง Hot Data กับ Cold Data
    while True:
        time.sleep(10) # บันทึกทุก 10 วินาที
        
        try:
            conn = sqlite3.connect(DB_NAME)
            cursor = conn.cursor()
            
            local_time = datetime.now()
            local_time_str = local_time.strftime("%Y-%m-%d %H:%M:%S")

            # [NEW] ดึงค่าล่าสุดจาก Redis (Hot Data)
            # ถ้าไม่มีค่าใน Redis ให้ใช้ 0
            vals = []
            for key in INTERESTED_KEYS:
                val = redis_client.get(key)
                vals.append(round(float(val), 2) if val else 0.0)

            # vals จะเรียงตามลำดับใน INTERESTED_KEYS: V1, V2, V3, I1, I2, I3, KW, KWH
            
            cursor.execute('''
                INSERT INTO meter_logs (timestamp, v1, v2, v3, i1, i2, i3, kw_total, kwh_total)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (local_time_str, *vals))
            
            conn.commit()
            conn.close()
            print(f"💾 Archived data from Redis to DB at {local_time_str}")
            
        except Exception as e:
            print(f"Error syncing Hot-to-Cold data: {e}")

# Start Threads
db_thread = threading.Thread(target=db_saver_loop)
db_thread.daemon = True
db_thread.start()

def start_mqtt():
    client = mqtt.Client()
    client.username_pw_set(MQTT_USER, MQTT_PASS)
    client.on_connect = on_connect
    client.on_message = on_message
    try: client.connect(MQTT_BROKER, MQTT_PORT, 60); client.loop_forever()
    except Exception as e: print(f"MQTT Error: {e}")

mqtt_thread = threading.Thread(target=start_mqtt)
mqtt_thread.daemon = True
mqtt_thread.start()

# ==========================================
# 4. API Endpoints (Read from Hot/Cold)
# ==========================================

# [Hot Data Access] อ่านจาก Redis โดยตรง เร็วมาก
@app.get("/api/dashboard")
def get_dashboard_data():
    try:
        # ดึงทุก Key ใน Redis (หรือจะเลือกเฉพาะ Keys ที่ต้องการก็ได้)
        keys = redis_client.keys("*")
        if not keys: return {}
        
        # ใช้ Pipeline ดึงค่าทีเดียวเพื่อลด Latency
        pipe = redis_client.pipeline()
        for k in keys: pipe.get(k)
        values = pipe.execute()
        
        # แปลงกลับเป็น Dict
        result = {k: (float(v) if v else 0) for k, v in zip(keys, values)}
        return result
    except Exception as e:
        return {"error": str(e)}

# [Cold Data Access] อ่านจาก SQLite เหมือนเดิม
@app.get("/api/history")
def get_history_data():
    try:
        conn = sqlite3.connect(DB_NAME)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM meter_logs ORDER BY id DESC LIMIT 1000") 
        rows = cursor.fetchall()
        conn.close()
        return [dict(row) for row in rows]
    except Exception as e:
        return {"error": str(e)}

# [Cold Data Export]
@app.get("/api/export_csv")
def export_csv_data():
    # (Code ส่วนนี้เหมือนเดิม เพราะดึงจาก SQLite)
    try:
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM meter_logs ORDER BY id DESC")
        rows = cursor.fetchall()
        if cursor.description is None: return {"error": "No data"}
        column_names = [description[0] for description in cursor.description]
        conn.close()

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(column_names)
        writer.writerows(rows)
        output.seek(0)
        
        filename = f"meter_data_{datetime.now().strftime('%Y%m%d_%H%M')}.csv"
        return StreamingResponse(iter([output.getvalue()]), media_type="text/csv", headers={"Content-Disposition": f"attachment; filename={filename}"})
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    run(app, host="0.0.0.0", port=8000)