import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
        client.subscribe("EMS/Auto_Target_Setpoint_KW_Add")
        client.subscribe("EMS/Load_Daily_Energy")
        client.subscribe("EMS/Load_Total_Energy")
        client.subscribe("EMS/GRID_Daily_Export_Energy")
        client.subscribe("EMS/GRID_Total_Export_Energy")
        client.subscribe("EMS/GRID_Daily_Import_Energy")
        client.subscribe("EMS/GRID_Total_Import_Energy")
        client.subscribe("EMS/BESS_Daily_Charge_Energy")
        client.subscribe("EMS/BESS_Total_Charge_Energy")
        client.subscribe("EMS/BESS_Daily_Discharge_Energy")
        client.subscribe("EMS/BESS_Total_Discharge_Energy")
        client.subscribe("EMS/PV_Daily_Energy")
        client.subscribe("EMS/PV_Total_Energy")
        client.subscribe("EMS/SETPOINT_ANTI_POWER_KW")
        client.subscribe("EMS/EMS_MODE")
        client.subscribe("EMS/Auto_Target_Setpoint_KW")
        client.subscribe("EMS/EMS_PID_OUT")
        client.subscribe("EMS/EMS_EnergyDischargeFromBESS_Daily")
        client.subscribe("EMS/EMS_EnergyChargeToBESS_Daily")
        client.subscribe("EMS/EMS_EnergyConsumption_Daily")
        client.subscribe("EMS/EMS_EnergyProducedFromPV_Daily")
        client.subscribe("EMS/EMS_EnergyFeedToGrid_Daily")
        client.subscribe("EMS/EMS_EnergyFeedFromGrid_Daily")
    else:
        print("Failed to connect, return code:", rc)

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()
    if topic == "EMS/Auto_Target_Setpoint_KW_Add":
        print(f"Auto Target Setpoint KW Add: {payload}")

    elif topic == "EMS/Load_Daily_Energy":
        print(f"Load Daily Energy: {payload} ")

    elif topic == "EMS/Load_Total_Energy":
        print(f"Load Total Energy: {payload}")

    elif topic == "EMS/GRID_Daily_Export_Energy":
        print(f"GRID Daily Export Energy: {payload} ")

    elif topic == "EMS/GRID_Total_Export_Energy":
        print(f"GRID Total Export Energy: {payload} ")

    elif topic == "EMS/GRID_Daily_Import_Energy":
        print(f"GRID Daily Import Energy: {payload} ")

    elif topic == "EMS/GRID_Total_Import_Energy":
        print(f"GRID Total Import Energy: {payload}")

    elif topic == "EMS/BESS_Daily_Charge_Energy":
        print(f"BESS Daily Charge Energ: {payload}")

    elif topic == "EMS/BESS_Total_Charge_Energy":
        print(f"BESS Total Charge Energy: {payload}")

    elif topic == "EMS/BESS_Daily_Discharge_Energy":
        print(f"BESS Daily Discharge Energy: {payload}")

    elif topic == "EMS/BESS_Total_Discharge_Energy":
        print(f"BESS Total Discharge Energy: {payload}")

    elif topic == "EMS/PV_Daily_Energy":
        print(f"PV Daily Energy: {payload}")

    elif topic == "EMS/PV_Total_Energy":
        print(f"PV Total Energy: {payload}")

    elif topic == "EMS/SETPOINT_ANTI_POWER_KW":
        print(f"SETPOINT ANTI POWER KW: {payload}")
    
    elif topic == "EMS/EMS_MODE":
        print(f"EMS MODE: {payload}")

    elif topic == "EMS/Auto_Target_Setpoint_KW":
        print(f"Auto Target Setpoint KW: {payload}")

    elif topic == "EMS/EMS_PID_OUT":
        print(f"EMS PID OUT: {payload}")

    elif topic == "EMS/EMS_EnergyDischargeFromBESS_Daily":
        print(f"EMS EnergyDischargeFromBESS Daily: {payload}")

    elif topic == "EMS/EMS_EnergyChargeToBESS_Daily":
        print(f"EMS EnergyChargeToBESS Daily: {payload}")

    elif topic == "EMS/EMS_EnergyConsumption_Daily":
        print(f"EMS EnergyConsumption Daily: {payload}")

    elif topic == "EMS/EMS_EnergyProducedFromPV_Daily":
        print(f"EMS EnergyProducedFromPV Daily: {payload}")

    elif topic == "EMS/EMS_EnergyFeedToGrid_Daily":
        print(f"EMS EnergyFeedToGrid Daily: {payload}")

    elif topic == "EMS/EMS_EnergyFeedFromGrid_Daily":
        print(f"EMS EnergyFeedFromGrid Daily: {payload}")

broker = "iicloud.tplinkdns.com"
port = 7036
username = "mqtt_user"
password = "ADMINktt5120@"
client_id = "python_client"

client = mqtt.Client(client_id)
client.username_pw_set(username, password)
client.on_connect = on_connect
client.on_message = on_message

try:
    client.connect(broker, port)
    client.loop_forever()
except Exception as e:
    print("Connection error:", e)
