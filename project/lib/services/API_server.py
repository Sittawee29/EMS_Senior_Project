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
from datetime import datetime, timedelta
import io
import csv
import redis

# ==========================================
# 1. Config & Setup
# ==========================================
MQTT_BROKER = "iicloud.tplinkdns.com"
MQTT_PORT = 7036
MQTT_USER = "mqtt_user"
MQTT_PASS = "ADMINktt5120@"
DB_NAME = "energy_data.db"

# Redis Configuration
REDIS_HOST = "localhost"
REDIS_PORT = 6379
REDIS_DB = 0

# เชื่อมต่อ Redis
try:
    redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
    redis_client.ping()
    print("\033[92m🗸\033[0m Connected to Redis")
except Exception as e:
    print(f"\033[91m𐄂\033[0m Failed to connect to Redis: {e}")

# รายชื่อ Keys ทั้งหมดที่จะใช้งาน
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
    "EMS_EnergyFeedFromGrid_Daily", "EMS_SolarPower_kW", "EMS_LoadPower_kW","EMS_BatteryPower_kW",
    "EMS_EnergyProducedFromPV_kWh", "EMS_EnergyFeedFromGrid_kWh", "EMS_EnergyConsumption_kWh",

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
    "PV2_ReactivePower_kW", "PV2_ApparentPower_kW", "PV2_Power_kW", "PV2_LifeTimeEnergyProduction",
    "PV2_PowerFactor_Percen", "PV2_ReactivePower", "PV2_ApparentPower", "PV2_Power", "PV2_Communication_Fault",

    # --- PV3 ---
    "PV3_Total_Power_Yields_Real", "PV3_Total_Apparent_Power_kW", "PV3_Total_Reactive_Power_kW", "PV3_Total_Active_Power_kW",
    "PV3_Total_Reactive_Power", "PV3_Total_Active_Power", "PV3_Total_Apparent_Power", "PV3_Total_Power_Yields",
    "PV3_Daily_Power_Yields", "PV3_Nominal_Active_Power", "PV3_Communication_Fault",

    # --- PV4 ---
    "PV4_Total_Power_Yields_Real", "PV4_Total_Apparent_Power_kW", "PV4_Total_Reactive_Power_kW", "PV4_Total_Active_Power_kW",
    "PV4_Total_Reactive_Power", "PV4_Total_Active_Power", "PV4_Total_Apparent_Power", "PV4_Total_Power_Yields",
    "PV4_Daily_Power_Yields", "PV4_Nominal_Active_Power", "PV4_Communication_Fault"
]

print("Initializing Redis keys...")
pipe = redis_client.pipeline()
for key in DEFAULT_KEYS:
    pipe.setnx(key, 0.0)
pipe.execute()
print("\033[92m🗸\033[0m Redis keys initialized complete.")
last_mqtt_update = time.time()

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    columns_sql = ", ".join([f'"{key}" REAL' for key in DEFAULT_KEYS])
    
    create_table_sql = f'''
        CREATE TABLE IF NOT EXISTS system_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME, 
            {columns_sql}
        )
    '''
    cursor.execute(create_table_sql)
    conn.commit()
    conn.close()
    print("\033[92m🗸\033[0m Database Initialized")

def init_db_wal_mode():
    max_retries = 5
    for i in range(max_retries):
        try:
            # เพิ่ม timeout=60 เพื่อให้โอกาสรอนานขึ้น
            with sqlite3.connect(DB_NAME, timeout=60) as conn:
                # สั่ง Commit เผื่อมี transaction ค้าง
                try: conn.execute("COMMIT") 
                except: pass
                
                cursor = conn.cursor()
                cursor.execute("PRAGMA journal_mode=WAL;")
                mode = cursor.fetchone()[0]
                
                if mode.upper() == 'WAL':
                    print(f"\033[92m🗸\033[0m Database WAL mode enabled. (Attempt {i+1})")
                    return
                else:
                    print(f"\033[93m⚠\033[0m WAL mode not set yet (Current: {mode}), retrying...")
                    
        except Exception as e:
            print(f"\033[93m⚠\033[0m Failed to enable WAL mode (Attempt {i+1}): {e}")
            time.sleep(1) # รอ 1 วินาทีก่อนลองใหม่
            
    print("\033[91m𐄂\033[0m Could not enable WAL mode after retries. System will continue but may be slow.")
    
init_db_wal_mode()

init_db()

app = FastAPI()
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

def get_energy_at_time(cursor, target_datetime):
    # แปลง datetime เป็น string format ใน database
    target_str = target_datetime.strftime("%Y-%m-%d %H:%M:%S")
    
    # Query หาค่า EMS_EnergyProducedFromPV_kWh ที่เวลา <= target_time ที่ใกล้ที่สุด
    sql = """
        SELECT "EMS_EnergyProducedFromPV_kWh"
        FROM system_logs 
        WHERE timestamp <= ?
        ORDER BY timestamp DESC
        LIMIT 1
    """
    cursor.execute(sql, (target_str,))
    row = cursor.fetchone()
    if row and row[0] is not None:
        return float(row[0])
    return 0.0

# ==========================================
# 2. MQTT Logic (Write to Hot Data)
# ==========================================
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT Broker!")
    topics = ["EMS/#", "BESS/#", "METER/#", "PV1/#", "PV2/#", "PV3/#", "PV4/#"]
    for t in topics: client.subscribe(t)

def on_message(client, userdata, msg):
    global latest_data, last_mqtt_update
    try:
        topic = msg.topic
        payload = msg.payload.decode("utf-8")
        #print(f"Topic: {topic} | Value: {payload}")
        updates = {}

        if "{" in payload and "}" in payload:
            try:
                data_json = json.loads(payload)
                
                def clean_val(v):
                    return round(float(v), 4) if isinstance(v, (int, float)) else v

                if "v1" in data_json: updates["METER_V1"] = clean_val(data_json["v1"])
                if "v2" in data_json: updates["METER_V2"] = clean_val(data_json["v2"])
                if "v3" in data_json: updates["METER_V3"] = clean_val(data_json["v3"])
                if "i1" in data_json: updates["METER_I1"] = clean_val(data_json["i1"])
                if "i2" in data_json: updates["METER_I2"] = clean_val(data_json["i2"])
                if "i3" in data_json: updates["METER_I3"] = clean_val(data_json["i3"])
                if "kwhtotal" in data_json: updates["METER_Total_KWH"] = clean_val(data_json["kwhtotal"])
                if "p" in data_json: updates["METER_KW"] = clean_val(data_json["p"])

                for key, val in data_json.items():
                    if isinstance(val, (int, float)):
                        
                        updates[key] = round(val, 4)
                last_mqtt_update = time.time()

            except json.JSONDecodeError:
                print(f"\033[91m𐄂\033[0m JSON Error: {payload}")
        else: 
            try:
                value = float(payload)
                if math.isnan(value) or math.isinf(value): value = 0.0
                value = round(value, 4)

                parts = topic.split("/")
                suffix = parts[-1]
                prefix = parts[0]
                if suffix in DEFAULT_KEYS:
                     key_name = suffix 
                else:
                     key_name = f"{prefix}_{suffix}"

                updates[key_name] = value
                
            except ValueError:
                pass 

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
# [EDITED] ฟังก์ชันนี้แก้ไขให้บันทึกทุก 5 นาที
def db_saver_loop():
    global last_mqtt_update
    print("\033[92m🗸\033[0m Database Saver Loop Started (Mode: Every 5 Minutes aligned to xx:00, xx:05, ...)")
    while True:
        try:
            time_diff = time.time() - last_mqtt_update
            if time_diff > 120:
                print(f"\033[93m⚠\033[0m Warning: No data for {int(time_diff)}s. Reconnecting MQTT...")
            now = datetime.now()
            
            if now.minute % 5 == 0:
                conn = sqlite3.connect(DB_NAME, timeout=30)
                cursor = conn.cursor()
                
                local_time_str = now.strftime("%Y-%m-%d %H:%M:%S")

                pipe = redis_client.pipeline()
                for key in DEFAULT_KEYS:
                    pipe.get(key)
                raw_values = pipe.execute()
                
                vals = []
                for v in raw_values:
                    try:
                        val_float = float(v) if v else 0.0
                        vals.append(round(val_float, 4))
                    except:
                        vals.append(0.0)

                columns_str = ", ".join([f'"{k}"' for k in DEFAULT_KEYS])
                placeholders = ", ".join(["?" for _ in DEFAULT_KEYS])
                
                sql = f'''
                    INSERT INTO system_logs (timestamp, {columns_str})
                    VALUES (?, {placeholders})
                '''
                
                cursor.execute(sql, (local_time_str, *vals))
                
                conn.commit()
                conn.close()
                print(f"\033[92m🗸\033[0m Archived data to DB at {local_time_str}")
                
                # สำคัญ: เมื่อบันทึกเสร็จแล้ว ให้ Sleep ข้ามนาทีนี้ไปเลย 
                # (เช่น 60 วินาที) เพื่อป้องกันการบันทึกซ้ำหลายรอบในนาทีเดียวกัน
                time.sleep(60) 
            
            else:
                # ถ้ายังไม่ถึงเวลา ให้รอ 10 วินาที แล้ววนกลับมาเช็คใหม่
                # การใช้ sleep น้อยๆ ช่วยให้เราไม่พลาดช่วงเปลี่ยนนาที
                time.sleep(10)
            
        except Exception as e:
            print(f"Error syncing Hot-to-Cold data: {e}")
            time.sleep(10) # ถ้า Error ให้รอหน่อยแล้วค่อยเริ่มใหม่

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

def on_disconnect(client, userdata, rc):
    if rc != 0:
        print("Unexpected disconnection. Attempting auto-reconnect...")
        try:
            client.reconnect()
        except:
            pass

# ... (ตรงส่วน Setup MQTT Client ด้านล่าง) ...
mqtt_client = mqtt.Client()
mqtt_client.username_pw_set(MQTT_USER, MQTT_PASS)
mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message
mqtt_client.on_disconnect = on_disconnect

# ==========================================
# 4. API Endpoints
# ==========================================

@app.get("/api/dashboard")
def get_dashboard_data():
    try:
        keys = redis_client.keys("*")
        if not keys: return {}
        pipe = redis_client.pipeline()
        for k in keys: pipe.get(k)
        values = pipe.execute()
        result = {k: (round(float(v), 4) if v else 0) for k, v in zip(keys, values)}
        return result
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 1. API หาช่วงวันที่ที่มีข้อมูล (Data Range)
# ==========================================
@app.get("/api/data_range")
def get_data_range():
    try:
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        # หาเวลาเริ่มต้นและสิ้นสุดที่มีข้อมูลใน DB
        cursor.execute("SELECT MIN(timestamp), MAX(timestamp) FROM system_logs")
        row = cursor.fetchone()
        conn.close()
        
        if row and row[0] and row[1]:
            return {"min_date": row[0], "max_date": row[1]}
        else:
            # ถ้าไม่มีข้อมูลเลย ให้ส่งวันปัจจุบันกลับไปป้องกัน Error
            now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            return {"min_date": now_str, "max_date": now_str}
    except Exception as e:
        return {"error": str(e)}
    
# ==========================================
# 2. API History ให้รับวันที่ (Daily)
# ==========================================
# เปลี่ยนชื่อจาก /api/history/today เป็น /api/history/daily
@app.get("/api/history/daily")
def get_daily_history(date: str = None):
    try:
        # ถ้าไม่ส่ง date มา ให้ใช้วันปัจจุบัน
        target_date = date if date else datetime.now().strftime("%Y-%m-%d")
        
        conn = sqlite3.connect(DB_NAME)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        # Query ข้อมูลตามวันที่ระบุ
        sql = "SELECT * FROM system_logs WHERE date(timestamp) = ? ORDER BY timestamp ASC"
        cursor.execute(sql, (target_date,))
        rows = cursor.fetchall()
        conn.close()
        
        results = [dict(row) for row in rows]
        return results
    except Exception as e:
        return {"error": str(e)}
    
# ==========================================
# 3. API History (Monthly)
# ==========================================
@app.get("/api/history/monthly")
def get_month_history(year: int = None, month: int = None):
    try:
        now = datetime.now()
        target_year = year if year else now.year
        target_month = month if month else now.month
        target_str = f"{target_year}-{target_month:02d}"

        conn = sqlite3.connect(DB_NAME)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Query แบบ Group By วัน (เอาค่าล่าสุดของวัน)
        sql = """
        SELECT * FROM system_logs 
        WHERE id IN (
            SELECT MAX(id) 
            FROM system_logs 
            WHERE strftime('%Y-%m', timestamp) = ? 
            GROUP BY strftime('%d', timestamp)
        )
        ORDER BY timestamp ASC
        """
        cursor.execute(sql, (target_str,))
        rows = cursor.fetchall()
        conn.close()

        results = []
        for row in rows:
            d = dict(row)
            if "EMS_LoadPower_kW" in d and d["EMS_LoadPower_kW"] is not None:
                d["EMS_LoadPower_kW"] = abs(d["EMS_LoadPower_kW"])
            results.append(d)
        return results
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 4. API History (Yearly)
# ==========================================
@app.get("/api/history/yearly")
def get_year_history(year: int = None):
    try:
        now = datetime.now()
        target_year = year if year else now.year
        target_str = f"{target_year}"

        conn = sqlite3.connect(DB_NAME)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Query แบบ Group By เดือน (เอาค่าล่าสุดของเดือน)
        sql = """
        SELECT * FROM system_logs 
        WHERE id IN (
            SELECT MAX(id) 
            FROM system_logs 
            WHERE strftime('%Y', timestamp) = ? 
            GROUP BY strftime('%m', timestamp)
        )
        ORDER BY timestamp ASC
        """
        cursor.execute(sql, (target_str,))
        rows = cursor.fetchall()
        conn.close()

        results = []
        for row in rows:
            d = dict(row)
            if "EMS_LoadPower_kW" in d and d["EMS_LoadPower_kW"] is not None:
                d["EMS_LoadPower_kW"] = abs(d["EMS_LoadPower_kW"])
            results.append(d)
        return results
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 5. API สำหรับ Overview Chart (Daily/Monthly/Yearly)
# ==========================================
@app.get("/api/overview")
def get_overview_summary(mode: str = "daily", date_str: str = None):
    try:
        # -------------------------------------------------------
        # 1. โหมด Daily: ดึงค่า Realtime จาก Redis (เหมือนเดิม)
        # -------------------------------------------------------
        if mode == "daily":
            keys_map = [
                "PV_Daily_Energy",           
                "BESS_Daily_Charge_Energy",  
                "GRID_Daily_Export_Energy",  
                "Load_Daily_Energy",         
                "GRID_Daily_Import_Energy",  
                "BESS_Daily_Discharge_Energy"
            ]
            pipe = redis_client.pipeline()
            for k in keys_map: pipe.get(k)
            res = pipe.execute()
            data = [float(x) if x else 0.0 for x in res]
            return data

        # -------------------------------------------------------
        # 2. โหมด Monthly / Yearly: ดึงจาก SQLite
        # -------------------------------------------------------
        now = datetime.now()
        target_date = now 
        if date_str:
            try:
                target_date = datetime.strptime(date_str, "%Y-%m-%d")
            except:
                pass # ถ้า format ผิด ให้ใช้เวลาปัจจุบัน

        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        
        # SQL Condition สำหรับกรองช่วงเวลา
        time_filter = ""
        debug_msg = ""

        if mode == "monthly":
            # กรอง "เดือน-ปี" เช่น '2026-01'
            t_str = target_date.strftime('%Y-%m')
            time_filter = f"strftime('%Y-%m', timestamp) = '{t_str}'"
            debug_msg = f"เดือน {t_str}"
        
        elif mode == "yearly":
            # กรอง "ปี" เช่น '2026'
            t_str = target_date.strftime('%Y')
            time_filter = f"strftime('%Y', timestamp) = '{t_str}'"
            debug_msg = f"ปี {t_str}"

        # -------------------------------------------------------
        # SQL LOGIC: 
        # 1. Subquery: หา MAX(id) ของแต่ละวัน (คือแถวสุดท้ายของวันนั้นๆ)
        # 2. Main Query: เอาค่าพลังงานของ id เหล่านั้นมารวมกัน (SUM)
        # -------------------------------------------------------
        sql = f"""
            SELECT 
                SUM("PV_Daily_Energy"),
                SUM("BESS_Daily_Charge_Energy"),
                SUM("GRID_Daily_Export_Energy"),
                SUM("Load_Daily_Energy"),
                SUM("GRID_Daily_Import_Energy"),
                SUM("BESS_Daily_Discharge_Energy")
            FROM system_logs 
            WHERE id IN (
                SELECT MAX(id) 
                FROM system_logs 
                WHERE {time_filter}
                GROUP BY strftime('%Y-%m-%d', timestamp)
            )
        """
        
        # --- เพิ่มส่วน Debug เพื่อเช็คว่าเจอวันไหนบ้าง ---
        check_sql = f"""
            SELECT strftime('%Y-%m-%d', timestamp), MAX(id) 
            FROM system_logs 
            WHERE {time_filter} 
            GROUP BY strftime('%Y-%m-%d', timestamp)
        """
        cursor.execute(check_sql)
        # ------------------------------------------------

        cursor.execute(sql)
        row = cursor.fetchone()
        conn.close()
        
        if row:
            # แปลง None เป็น 0.0
            result = [float(x) if x is not None else 0.0 for x in row]
            return result
        else:
            return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    except Exception as e:
        print(f"Error overview: {e}")
        return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

@app.get("/api/export_csv")
def export_csv_data():
    try:
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM system_logs ORDER BY id DESC")
        rows = cursor.fetchall()
        if cursor.description is None: return {"error": "No data"}
        column_names = [description[0] for description in cursor.description]
        conn.close()

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(column_names)
        writer.writerows(rows)
        output.seek(0)
        
        filename = f"system_data_{datetime.now().strftime('%Y%m%d_%H%M')}.csv"
        return StreamingResponse(iter([output.getvalue()]), media_type="text/csv", headers={"Content-Disposition": f"attachment; filename={filename}"})
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/bill/reading_start")
def get_reading_start():
    try:
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        
        # หาวันที่ 27 ของเดือนปัจจุบัน
        now = datetime.now()
        target_day = 27
        
        # สร้าง string วันที่เป้าหมาย เช่น '2023-10-27'
        # หมายเหตุ: ถ้าวันนี้ยังไม่ถึงวันที่ 27 ระบบจะหาไม่เจอ (อาจต้องปรับ Logic เป็นเดือนก่อนหน้าถ้าต้องการรอบบิลจริง)
        # แต่ทำตามโจทย์คือ "เดือนปัจจุบัน"
        target_date_str = f"{now.year}-{now.month:02d}-{target_day:02d}"
        
        # Query หาค่าที่เวลาใกล้ 00:00:00 ที่สุด ของวันที่ 27 เดือนปัจจุบัน
        sql = f"""
            SELECT "EMS_EnergyProducedFromPV_kWh"
            FROM system_logs 
            WHERE strftime('%Y-%m-%d', timestamp) = ?
            ORDER BY ABS(strftime('%H', timestamp) * 3600 + strftime('%M', timestamp) * 60) ASC
            LIMIT 1
        """
        
        cursor.execute(sql, (target_date_str,))
        row = cursor.fetchone()
        conn.close()

        if row and row[0] is not None:
            return {"prev_read": float(row[0])}
        else:
            # ถ้าหาไม่เจอ (เช่น ยังไม่ถึงวันที่ 27) ให้ส่ง 0 หรือค่าล่าสุดที่มีไปก่อน
            return {"prev_read": 0.0}

    except Exception as e:
        print(f"Error fetching start reading: {e}")
        return {"prev_read": 0.0}
    
@app.get("/api/bill/calculate_tou")
def calculate_tou_units():
    try:
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        
        now = datetime.now()
        
        # 1. หาวันที่เริ่มต้นรอบบิล (วันที่ 27)
        if now.day >= 27:
            start_date = datetime(now.year, now.month, 27, 0, 0, 0)
        else:
            # ย้อนกลับไปเดือนก่อนหน้า
            if now.month == 1:
                start_date = datetime(now.year - 1, 12, 27, 0, 0, 0)
            else:
                start_date = datetime(now.year, now.month - 1, 27, 0, 0, 0)
        
        total_on_peak = 0.0
        total_off_peak = 0.0
        total_holiday = 0.0
        
        # 2. วนลูปตั้งแต่วันเริ่มต้น จนถึงวันนี้
        current_date = start_date
        # เราจะคำนวณทีละวัน (จบที่วันปัจจุบัน + 1 เพื่อให้ครอบคลุมวันนี้)
        end_date = datetime(now.year, now.month, now.day) + timedelta(days=1)
        
        while current_date < end_date:
            # current_date คือเวลา 00:00 ของวันนั้นๆ
            weekday = current_date.weekday() # 0=Mon, 1=Tue, ..., 5=Sat, 6=Sun
            
            # --- จันทร์ (0) ถึง ศุกร์ (4) ---
            if 0 <= weekday <= 4:
                # กำหนดเวลา 09:00 และ 22:00 ของวันนั้น
                time_00 = current_date.replace(hour=0, minute=0)
                time_09 = current_date.replace(hour=9, minute=0)
                time_22 = current_date.replace(hour=22, minute=0)
                
                # ถ้าเวลาที่จะดึง เป็นอนาคตเกินไป ให้ข้าม หรือใช้ค่าปัจจุบันแทน (ที่นี้ขอข้ามถ้าเกิน now)
                if time_00 <= now:
                     val_00 = get_energy_at_time(cursor, time_00)
                     
                     # 1. Off Peak (จ-ศ): 09:00 - 00:00
                     if time_09 <= now:
                         val_09 = get_energy_at_time(cursor, time_09)
                         # คำนวณ Off Peak
                         diff = val_09 - val_00
                         if diff > 0: total_off_peak += diff
                         
                         # 2. On Peak (จ-ศ): 22:00 - 09:00
                         if time_22 <= now:
                             val_22 = get_energy_at_time(cursor, time_22)
                         else:
                             # ถ้ายังไม่ถึง 22:00 ให้ใช้ค่าล่าสุด ณ ตอนนี้ (Realtime)
                             val_22 = get_energy_at_time(cursor, now)
                             
                         diff_on = val_22 - val_09
                         if diff_on > 0: total_on_peak += diff_on
                     else:
                         # กรณีวันนี้ยังไม่ถึง 09:00 (ได้ Off Peak บางส่วน)
                         val_now = get_energy_at_time(cursor, now)
                         diff = val_now - val_00
                         if diff > 0: total_off_peak += diff

            # --- เสาร์ (5) ---
            # Holiday คิดรวบยอด: จันทร์ถัดไป(00:00) - เสาร์(00:00)
            elif weekday == 5:
                time_sat_00 = current_date.replace(hour=0, minute=0)
                time_next_mon_00 = time_sat_00 + timedelta(days=2) # ข้ามอาทิตย์ไปจันทร์
                
                if time_sat_00 <= now:
                    val_sat = get_energy_at_time(cursor, time_sat_00)
                    
                    if time_next_mon_00 <= now:
                        val_mon = get_energy_at_time(cursor, time_next_mon_00)
                    else:
                        # ถ้ายังไม่ถึงเช้าวันจันทร์ ให้ใช้ค่าล่าสุด (Realtime)
                        val_mon = get_energy_at_time(cursor, now)
                    
                    diff_holiday = val_mon - val_sat
                    if diff_holiday > 0: total_holiday += diff_holiday
            
            # ขยับไปวันถัดไป
            current_date += timedelta(days=1)

        conn.close()
        
        return {
            "on_peak_unit": total_on_peak,
            "off_peak_unit": total_off_peak,
            "holiday_unit": total_holiday
        }

    except Exception as e:
        print(f"Error calculating TOU: {e}")
        return {"on_peak_unit": 0, "off_peak_unit": 0, "holiday_unit": 0}
    
if __name__ == "__main__":
    print("Initializing Database...")
    init_db_wal_mode()
    print("Starting Server...")
    run(app, host="0.0.0.0", port=8000)