#include <ArduinoJson.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <DHT.h>

#define DHTPIN 16
#define DHTTYPE DHT11

// Khai báo các thông số cho sever BLE
#define SERVICE_UUID "87e3a34b-5a54-40bb-9d6a-355b9237d42b"
#define CHARACTERISTIC_UUID "cdc7651d-88bd-4c0d-8c90-4572db5aa14b"
#define SERVERNAME "Amazing_Tech"

DHT dht(DHTPIN, DHTTYPE);

BLEServer* pServer = NULL;
BLEService* pService = NULL;
BLECharacteristic* dhtCharacteristic = NULL;
BLEAdvertising* pAdvertising = NULL;

float nhietbonnong = 0.0;
float nhietbonlanh = 0.0;
float nguongbonnong = 70.0;
float nguongbonlanh = 3.0;
int dungtich = 300;
int soluongchai = 0;
bool deviceConnected = false;


DynamicJsonDocument sendDoc(1024);
DynamicJsonDocument receivedDoc(1024);

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Thiết bị: Đã kết nối!");
  };

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Thiết bị: Ngắt kết nối!");
    BLEDevice::startAdvertising();
  }
};

// Nhận dữ liệu
class CharacteristicCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* dhtCharacteristic) {
    String value = dhtCharacteristic->getValue().c_str();

    if (deserializeJson(receivedDoc, value.c_str()) == DeserializationError::Ok) {
      if (receivedDoc.containsKey("nguongbonnong")) {
        nguongbonnong = receivedDoc["nguongbonnong"].as<float>();
      }
      if (receivedDoc.containsKey("nguongbonlanh")) {
        nguongbonlanh = receivedDoc["nguongbonlanh"].as<float>();
      }
      if (receivedDoc.containsKey("dungtich")) {
        dungtich = receivedDoc["dungtich"].as<int>();
      }
    }
  }
};

void setupBle() {
  Serial.println("Thiết lập...");
  BLEDevice::init(SERVERNAME);

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  pService = pServer->createService(SERVICE_UUID);
  dhtCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

  dhtCharacteristic->addDescriptor(new BLE2902());
  dhtCharacteristic->setCallbacks(new CharacteristicCallback());

  pService->start();

  pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();

  Serial.println("Thiết lập thành công. Chờ thiết bị kết nối...");
}

void getDhtData() {
  float temperature = dht.readTemperature();

  if (!isnan(temperature)) {
    nhietbonnong = temperature; // Tạm thời lấy từ một cảm biến
    nhietbonlanh = temperature; // Tạm thời lấy từ một cảm biến
  } else {
    Serial.println("DHT sensor error!");
  }
}

// Hàm Gửi dữ liệu
void sendData() {
  sendDoc["nhietbonnong"] = nhietbonnong;
  sendDoc["nhietbonlanh"] = nhietbonlanh;
  sendDoc["nguongbonnong"] = nguongbonnong;
  sendDoc["nguongbonlanh"] = nguongbonlanh;
  sendDoc["dungtich"] = dungtich;
  sendDoc["soluongchai"] = soluongchai;

  String data;
  serializeJson(sendDoc, data);
  Serial.println(data);

  dhtCharacteristic->setValue(data.c_str());
  dhtCharacteristic->notify();
}

void setup() {
  Serial.begin(115200);
  setupBle();
  dht.begin();
}

void loop() {
  getDhtData();

  if (deviceConnected) {
    sendData();
  }

  delay(5000);
}
