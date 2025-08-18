import paho.mqtt.publish as publish

publish.single("test/topic", "hello from flask test", hostname="192.168.1.213")
print("MQTT message sent")