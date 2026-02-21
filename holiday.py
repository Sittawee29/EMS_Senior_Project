import requests
import json
from datetime import datetime

# 1. ตั้งค่า URL และปีที่ต้องการค้นหา
year = "2026" # ปี ค.ศ.
url = f"https://gateway.api.bot.or.th/financial-institutions-holidays/?year=2026"

my_token = "eyJvcmciOiI2NzM1NzgwZWM4YzFlYjAwMDEyYTM3NzEiLCJpZCI6IjNhNGViOGU0YTY5NjQ5ZmJhMDU3MjlmMThiZmRiOTQzIiwiaCI6Im11cm11cjEyOCJ9"

# 2. ตั้งค่า Headers แบบใหม่ (เพิ่มคำว่า Bearer เข้าไป)
headers = {
    'X-IBM-Client-Id': my_token,           # ใส่เผื่อไว้สำหรับระบบเก่าบางตัว
    'Authorization': f'Bearer {my_token}', # ✨ บรรทัดนี้คือหัวใจสำคัญที่แก้ Error 401!
    'accept': 'application/json'
}

try:
    # 3. ยิง Request ไปที่ BOT
    response = requests.get(url, headers=headers)

    # 4. ตรวจสอบสถานะและแสดงผล
    if response.status_code == 200:
        data = response.json()
        
        # เข้าถึง list ของวันหยุด (โครงสร้างอาจเปลี่ยนตาม Version API แต่ส่วนใหญ่จะอยู่ใน key 'result' -> 'data')
        holidays = data['result']['data']
        
        print(f"--- วันหยุดธนาคาร ปี {year} ---")
        for day in holidays:
            date_str = day['Date']
            name = day['HolidayDescription'] # หรือใช้ HolidayNameThai
            print(f"วันที่: {date_str} -> {name}")
            
    else:
        print(f"Error: {response.status_code}")
        print(response.text)

except Exception as e:
    print(f"เกิดข้อผิดพลาด: {e}")