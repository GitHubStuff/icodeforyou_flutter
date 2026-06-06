# Bluetooth Low Energy (BLE)

Bluetooth Low Energy is a wireless protocol optimized for low power consumption, small data payloads, and intermittent communication. It is ideal for devices that run on coin cells for months or years. BLE shines wherever you need cheap, low-power, short-range connectivity with modest bandwidth — it's a sip of data, not a firehose.

## Top 20 Uses

1. **Fitness trackers and smartwatches** — syncing step counts, heart rate, and activity data to a phone.
2. **Health and medical devices** — glucose monitors, blood pressure cuffs, pulse oximeters, and continuous glucose monitors (CGMs).
3. **Wireless earbuds and hearing aids** — though audio streaming often uses BLE Audio (LE Audio) with the LC3 codec.
4. **Proximity beacons** — iBeacon and Eddystone for indoor navigation, retail promotions, and museum exhibits.
5. **Asset tracking tags** — Apple AirTag, Tile, and Samsung SmartTag for finding keys, luggage, and pets.
6. **Smart home devices** — locks, light bulbs, thermostats, and sensors (often as a setup/commissioning channel before handing off to Wi-Fi or Thread).
7. **Keyless entry and access control** — phone-as-key for cars, offices, and hotel rooms.
8. **Contact tracing** — the Apple/Google Exposure Notification framework used during COVID-19.
9. **Indoor positioning and wayfinding** — airports, hospitals, and large retail spaces.
10. **Industrial IoT sensors** — temperature, vibration, humidity, and pressure monitoring in factories.
11. **Retail and proximity marketing** — pushing location-aware offers to shoppers' phones.
12. **Wireless peripherals** — keyboards, mice, styluses, and game controllers.
13. **Environmental sensors** — air quality monitors, soil sensors, and weather stations.
14. **Vehicle telematics and tire pressure monitoring** — short-range diagnostics and TPMS.
15. **Wearable payment and ticketing** — transit passes and contactless wearables.
16. **Toys and educational devices** — connected robots, smart toys, and STEM kits.
17. **Agricultural and livestock monitoring** — animal trackers and field sensors.
18. **Logistics and supply chain** — temperature-logging tags for cold-chain shipments.
19. **Device provisioning and configuration** — using BLE as an out-of-band channel to onboard headless devices onto Wi-Fi.
20. **Mesh networking** — Bluetooth Mesh for large-scale lighting control and building automation.

## Platform Notes

The developer story differs by platform:

- **iOS / macOS** — CoreBluetooth
- **Android** — the Android BLE APIs
- **Flutter (cross-platform)** — a plugin such as `flutter_blue_plus`
