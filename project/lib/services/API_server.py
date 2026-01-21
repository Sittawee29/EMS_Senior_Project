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

# ==========================================
# 1. Config & Database Setup
# ==========================================
MQTT_BROKER = "iicloud.tplinkdns.com"
MQTT_PORT = 7036
MQTT_USER = "mqtt_user"
MQTT_PASS = "ADMINktt5120@"
DB_NAME = "energy_data.db"

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
    print("✅ Database Initialized")

init_db()

# ==========================================
# 2. Data Store
# ==========================================
current_data = {
    # METER
    "METER_V1": 0.0, "METER_V2": 0.0, "METER_V3": 0.0,
    "METER_I1": 0.0, "METER_I2": 0.0, "METER_I3": 0.0,
    "METER_KW": 0.0, "METER_Total_KWH": 0.0,
    
    # Other Variables
    "PV_Total_Energy": 0.0, "PV_Daily_Energy": 0.0, "Load_Total_Energy": 0.0, "Load_Daily_Energy": 0.0,
    "GRID_Total_Import_Energy": 0.0, "GRID_Daily_Import_Energy": 0.0, "GRID_Total_Export_Energy": 0.0, "GRID_Daily_Export_Energy": 0.0,
    "BESS_Daily_Charge_Energy": 0.0, "BESS_Daily_Discharge_Energy": 0.0, "EMS_CO2_Equivalent": 0.0,
    "EMS_EnergyProducedFromPV_Daily": 0.0, "EMS_EnergyFeedToGrid_Daily": 0.0, "EMS_EnergyConsumption_Daily": 0.0,
    "EMS_EnergyFeedFromGrid_Daily": 0.0, "EMS_SolarPower_kW": 0.0, "EMS_LoadPower_kW": 0.0,
    "BESS_SOC": 0.0, "BESS_SOH": 0.0, "BESS_V": 0.0, "BESS_I": 0.0, "BESS_KW": 0.0, "BESS_Temperature": 0.0,
    "BESS_Total_Discharge": 0.0, "BESS_Total_Charge": 0.0, "BESS_SOC_MAX": 0.0, "BESS_SOC_MIN": 0.0,
    "BESS_Power_KW_Invert": 0.0, "BESS_Manual_Power_Setpoint": 0.0, "BESS_PID_CycleTime": 0.0,
    "BESS_PID_Td": 0.0, "BESS_PID_Ti": 0.0, "BESS_PID_Gain": 0.0, "BESS_Temp_Ambient": 0.0,
    "BESS_Alarm": 0.0, "BESS_Fault": 0.0, "BESS_Communication_Fault": 0.0,
    "METER_Export_KVARH": 0.0, "METER_Export_KWH": 0.0, "METER_Import_KVARH": 0.0, "METER_Import_KWH": 0.0,
    "METER_Total_KVARH": 0.0, "METER_Hz": 0.0, "METER_PF": 0.0,
    "METER_I_Total": 0.0, "METER_KVAR": 0.0, "METER_KW_Invert": 0.0, "METER_Grid_Power_KW": 0.0,
    "PV1_Grid_Power_KW": 0.0, "PV1_Load_Power_KW": 0.0, "PV1_Daily_Energy_Power_KWh": 0.0, "PV1_Total_Energy_Power_KWh": 0.0,
    "PV1_Power_Factor": 0.0, "PV1_Reactive_Power_KVar": 0.0, "PV1_Active_Power_KW": 0.0, "PV1_Fault": 0.0, "PV1_Communication_Fault": 0.0,
}

app = FastAPI()
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

# ==========================================
# 3. MQTT Logic
# ==========================================
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT Broker!")
    topics = ["EMS/#", "BESS/#", "METER/#", "PV1/#", "PV2/#", "PV3/#", "PV4/#", "bdmsry/meter"]
    for t in topics: client.subscribe(t)

def on_message(client, userdata, msg):
    global current_data
    try:
        topic = msg.topic
        payload = msg.payload.decode("utf-8")
        
        # JSON Payload
        if "{" in payload and "}" in payload:
            data_json = json.loads(payload)
            if "v1" in data_json: current_data["METER_V1"] = float(data_json["v1"])
            if "v2" in data_json: current_data["METER_V2"] = float(data_json["v2"])
            if "v3" in data_json: current_data["METER_V3"] = float(data_json["v3"])
            if "i1" in data_json: current_data["METER_I1"] = float(data_json["i1"])
            if "i2" in data_json: current_data["METER_I2"] = float(data_json["i2"])
            if "i3" in data_json: current_data["METER_I3"] = float(data_json["i3"])
            if "kwhtotal" in data_json: current_data["METER_Total_KWH"] = float(data_json["kwhtotal"])
            if "p" in data_json: current_data["METER_KW"] = float(data_json["p"])

        # Simple Payload
        else: 
            value = float(payload)
            if math.isnan(value) or math.isinf(value): value = 0.0
            
            parts = topic.split("/")
            if len(parts) >= 2:
                prefix = parts[0]
                suffix = parts[-1]
                
                # Smart Mapping Logic
                if suffix in current_data:
                    current_data[suffix] = value
                elif f"{prefix}_{suffix}" in current_data:
                    current_data[f"{prefix}_{suffix}"] = value
                else:
                    for key in current_data:
                        if key.lower().endswith(suffix.lower()):
                            current_data[key] = value
                            break

    except Exception as e: pass

# ==========================================
# 4. Background Tasks
# ==========================================
def db_saver_loop():
    while True:
        time.sleep(10) # 1 นาที
        
        try:
            conn = sqlite3.connect(DB_NAME)
            cursor = conn.cursor()
            
            local_time = datetime.now()
            local_time_str = local_time.strftime("%Y-%m-%d %H:%M:%S")

            # บันทึกแบบทศนิยม 2 ตำแหน่ง
            data_to_save = (
                local_time_str, 
                round(current_data.get("METER_V1", 0), 2),
                round(current_data.get("METER_V2", 0), 2),
                round(current_data.get("METER_V3", 0), 2),
                round(current_data.get("METER_I1", 0), 2),
                round(current_data.get("METER_I2", 0), 2),
                round(current_data.get("METER_I3", 0), 2),
                round(current_data.get("METER_KW", 0), 2),
                round(current_data.get("METER_Total_KWH", 0), 2)
            )
            
            cursor.execute('''
                INSERT INTO meter_logs (timestamp, v1, v2, v3, i1, i2, i3, kw_total, kwh_total)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', data_to_save)
            
            conn.commit()
            conn.close()
            print(f"💾 Saved data at {local_time_str}")
            
        except Exception as e:
            print(f"Error saving to DB: {e}")

# Start DB Thread
db_thread = threading.Thread(target=db_saver_loop)
db_thread.daemon = True
db_thread.start()

# *** จุดที่แก้ไข: สร้างฟังก์ชัน start_mqtt ก่อนเรียกใช้ ***
def start_mqtt():
    client = mqtt.Client()
    client.username_pw_set(MQTT_USER, MQTT_PASS)
    client.on_connect = on_connect
    client.on_message = on_message
    try: client.connect(MQTT_BROKER, MQTT_PORT, 60); client.loop_forever()
    except Exception as e: print(f"MQTT Error: {e}")

# Start MQTT Thread
mqtt_thread = threading.Thread(target=start_mqtt)
mqtt_thread.daemon = True
mqtt_thread.start()

# ==========================================
# 5. API Endpoints
# ==========================================
@app.get("/api/dashboard")
def get_dashboard_data():
    return current_data

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

@app.get("/api/export_csv")
def export_csv_data():
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