from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware 
import threading
import json
import paho.mqtt.client as mqtt
from uvicorn import run

# 1. Config MQTT
MQTT_BROKER = "iicloud.tplinkdns.com"
MQTT_PORT = 7036
MQTT_USER = "mqtt_user"
MQTT_PASS = "ADMINktt5120@"

# 2. ตัวแปรเก็บข้อมูลล่าสุด (In-memory Database)
current_data = {
    # EMS (ชื่อตรงกับ Flutter โดยไม่ต้องมี EMS_ นำหน้า)
    "PV_Total_Energy": 0.0,
    "PV_Daily_Energy": 0.0,
    "Load_Total_Energy": 0.0,
    "Load_Daily_Energy": 0.0,
    "GRID_Total_Import_Energy": 0.0,
    "GRID_Daily_Import_Energy":  0.0,
    "GRID_Total_Export_Energy": 0.0,
    "GRID_Daily_Export_Energy": 0.0,
    "BESS_Daily_Charge_Energy": 0.0,
    "BESS_Daily_Discharge_Energy": 0.0,
    "EMS_CO2_Equivalent": 0.0,
    "EMS_EnergyProducedFromPV_Daily": 0.0,
    "EMS_EnergyFeedToGrid_Daily": 0.0,
    "EMS_EnergyConsumption_Daily": 0.0,
    "EMS_EnergyFeedFromGrid_Daily": 0.0,
    "EMS_SolarPower_kW": 0.0,
    "EMS_LoadPower_kW": 0.0,
    
    # BESS
    "BESS_SOC": 0.0,
    "BESS_SOH": 0.0,
    "BESS_V": 0.0,
    "BESS_I": 0.0,
    "BESS_KW": 0.0,
    "BESS_Temperature": 0.0,
    "BESS_Total_Discharge": 0.0,
    "BESS_Total_Charge": 0.0,
    "BESS_SOC_MAX": 0.0,
    "BESS_SOC_MIN": 0.0,
    "BESS_Power_KW_Invert": 0.0,
    "BESS_Manual_Power_Setpoint": 0.0,
    "BESS_PID_CycleTime": 0.0,
    "BESS_PID_Td": 0.0,
    "BESS_PID_Ti": 0.0,
    "BESS_PID_Gain": 0.0,
    "BESS_Temp_Ambient": 0.0,
    "BESS_Alarm": 0.0,
    "BESS_Fault": 0.0,
    "BESS_Communication_Fault": 0.0,
    
    # METER
    "METER_Export_KVARH": 0.0,
    "METER_Export_KWH": 0.0,
    "METER_Import_KVARH": 0.0,
    "METER_Import_KWH": 0.0,
    "METER_Total_KVARH": 0.0,
    "METER_Total_KWH": 0.0,
    "METER_Hz": 0.0,
    "METER_PF": 0.0,
    "METER_V1": 0.0,
    "METER_V2": 0.0,
    "METER_V3": 0.0,
    "METER_I1": 0.0,
    "METER_I2": 0.0,
    "METER_I3": 0.0,
    "METER_I_Total": 0.0,
    "METER_KW": 0.0,
    "METER_KVAR": 0.0,
    "METER_KW_Invert": 0.0,
    "METER_Grid_Power_KW": 0.0,
    
    # PV1
    "PV1_Grid_Power_KW": 0.0,
    "PV1_Load_Power_KW": 0.0,
    "PV1_Daily_Energy_Power_KWh": 0.0,
    "PV1_Total_Energy_Power_KWh": 0.0,
    "PV1_Power_Factor": 0.0,
    "PV1_Reactive_Power_KVar": 0.0,
    "PV1_Active_Power_KW": 0.0,
    "PV1_Fault": 0.0,
    "PV1_Communication_Fault": 0.0,
    
    # PV2
    "PV2_Energy_Daily_kW": 0.0,
    "PV2_LifeTimeEnergyProduction_kWh_Start": 0.0,
    "PV2_LifeTimeEnergyProduction_kWh": 0.0,
    "PV2_ReactivePower_kW": 0.0,
    "PV2_ApparentPower_kW": 0.0,
    "PV2_Active_Power_kW": 0.0,
    "PV2_LifeTimeEnergyProduction": 0.0,
    "PV2_PowerFactor_Percen": 0.0,
    "PV2_ReactivePower": 0.0,
    "PV2_ApparentPower": 0.0,
    "PV2_Power": 0.0,
    "PV2_Communication_Fault": 0.0,

    # PV3
    "PV3_Total_Power_Yields_Real": 0.0,
    "PV3_Total_Apparent_Power_kW": 0.0,
    "PV3_Total_Reactive_Power_kW": 0.0,
    "PV3_Active_Power_kW": 0.0,
    "PV3_Total_Reactive_Power": 0.0,
    "PV3_Total_Active_Power": 0.0,
    "PV3_Total_Apparent_Power": 0.0,
    "PV3_Total_Power_Yields": 0.0,
    "PV3_Daily_Power_Yields": 0.0,
    "PV3_Nominal_Active_Power": 0.0,
    "PV3_Communication_Fault": 0.0,

    # PV4
    "PV4_Total_Power_Yields_Real": 0.0,
    "PV4_Total_Apparent_Power_kW": 0.0,
    "PV4_Total_Reactive_Power_kW": 0.0,
    "PV4_Active_Power_kW": 0.0,
    "PV4_Total_Reactive_Power": 0.0,
    "PV4_Total_Active_Power": 0.0,
    "PV4_Total_Apparent_Power": 0.0,
    "PV4_Total_Power_Yields": 0.0,
    "PV4_Daily_Power_Yields": 0.0,
    "PV4_Nominal_Active_Power": 0.0,
    "PV4_Communication_Fault": 0.0,
}

# 3. สร้าง FastAPI
app = FastAPI()

# --- [ส่วนสำคัญที่เพิ่มเข้ามา] แก้ปัญหา CORS Error ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # อนุญาตให้ทุกเว็บเข้าถึงได้
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# -----------------------------------------------

# ฟังก์ชันเมื่อต่อ MQTT สำเร็จ
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT Broker!")
    topics = [
        "EMS/#", "BESS/#", "METER/#", 
        "PV1/#", "PV2/#", "PV3/#", "PV4/#"
    ]
    for t in topics:
        client.subscribe(t)

def on_message(client, userdata, msg):
    global current_data
    topic = msg.topic
    payload = msg.payload.decode("utf-8")
    
    try:
        value = float(payload)
        parts = topic.split("/")
        
        if len(parts) >= 2:
            prefix = parts[0]
            suffix = parts[-1]
            
            # Logic: เช็คว่า Key ไหนมีใน Database ให้ใช้ Key นั้น
            if suffix in current_data:
                key = suffix
            elif f"{prefix}_{suffix}" in current_data:
                key = f"{prefix}_{suffix}"
            elif suffix.startswith(prefix):
                key = suffix
            else:
                key = f"{prefix}_{suffix}"
        else:
            key = topic

        # อัปเดตข้อมูล
        if key in current_data:
            current_data[key] = value
        
        # print(f"Updated: {key} = {value}")
        
    except ValueError:
        pass

# 4. เริ่มทำงาน MQTT
def start_mqtt():
    client = mqtt.Client()
    client.username_pw_set(MQTT_USER, MQTT_PASS)
    client.on_connect = on_connect
    client.on_message = on_message
    
    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_forever()
    except Exception as e:
        print(f"MQTT Connection Error: {e}")

mqtt_thread = threading.Thread(target=start_mqtt)
mqtt_thread.daemon = True
mqtt_thread.start()

# 5. API Endpoint
@app.get("/api/dashboard")
def get_dashboard_data():
    return current_data

if __name__ == "__main__":
    run(app, host="0.0.0.0", port=8000)