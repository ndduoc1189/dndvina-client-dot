# Android Phone Controller

Thư viện Python để điều khiển điện thoại Android thông qua API của một APK trợ năng.

## Tính năng chính

- Tương tác với màn hình (tap, swipe, long press)
- Nhập văn bản với tốc độ giống người thật
- Quản lý ứng dụng (mở/đóng)
- Phân tích cấu trúc UI và tìm kiếm phần tử trên màn hình
- Thực hiện các thao tác chờ đợi một cách thông minh
- Xử lý XML trực tiếp để tìm kiếm phần tử

## Cài đặt

1. Clone repository:
```bash
git clone https://github.com/yourusername/android-phone-controller.git
cd android-phone-controller
```

2. Cài đặt các thư viện phụ thuộc:
```bash
pip install -r requirements.txt
```

3. Đảm bảo APK trợ năng đã được cài đặt trên thiết bị Android và đã bật dịch vụ.

## Cấu trúc thư mục

```
.
├── services/                  # Thư mục chứa các dịch vụ
│   ├── __init__.py            # File khởi tạo cho package
│   └── helper_service.py      # Lớp chính để điều khiển điện thoại
├── examples.py                # Các ví dụ sử dụng cơ bản
├── tiktok_bot.py              # Bot tự động cho TikTok
├── requirements.txt           # Các thư viện phụ thuộc
└── README.md                  # Tài liệu hướng dẫn
```

## Cách sử dụng

### Cơ bản

```python
from services.helper_service import HelperService

# Khởi tạo controller với URL của APK trợ năng
controller = HelperService(base_url="http://localhost:8080")

# Mở ứng dụng
controller.open_app("com.example.app")

# Tìm và chạm vào phần tử
element = controller.find_element(text="Login")
if element:
    controller.tap_element(element.get("bounds"))

# Nhập văn bản
controller.input_text("Hello world")

# Vuốt màn hình
controller.swipe_up()
```

### Chạy các ví dụ

```bash
python examples.py
```

### Chạy bot TikTok

```bash
python tiktok_bot.py
```

## API chính

### HelperService

Lớp chính để tương tác với thiết bị Android.

#### Khởi tạo

```python
controller = HelperService(base_url="http://localhost:8080")
```

#### Tương tác cơ bản

- `tap(x, y)`: Chạm vào vị trí x,y trên màn hình
- `tap_element(bounds)`: Chạm vào phần tử dựa trên bounds
- `swipe_up()`: Vuốt lên từ vị trí ngẫu nhiên phù hợp
- `swipe_down()`: Vuốt xuống từ vị trí ngẫu nhiên phù hợp
- `swipe(start_x, start_y, end_x, end_y, duration)`: Vuốt từ điểm A đến điểm B
- `long_press(x, y, duration)`: Nhấn giữ tại vị trí x,y
- `input_text(text, speed, direct_mode, perfect_mode)`: Nhập văn bản

#### Quản lý ứng dụng

- `open_app(package, activity)`: Mở ứng dụng với package name
- `close_app(package)`: Đóng ứng dụng

#### Điều hướng

- `press_back()`: Nhấn nút Back
- `press_home()`: Nhấn nút Home
- `press_recent_apps()`: Nhấn nút Recent Apps

#### Phân tích UI

- `dump_screen_xml()`: Lấy cấu trúc XML của màn hình hiện tại
- `find_element(text, content_desc, resource_id)`: Tìm phần tử trên màn hình
- `find_all_elements(text, content_desc, resource_id, class_name)`: Tìm tất cả phần tử phù hợp
- `wait_for_element(text, content_desc, resource_id, timeout, check_interval)`: Chờ đến khi phần tử xuất hiện

#### Thuộc tính phần tử

- `get_element_text(element)`: Lấy text của phần tử
- `get_element_content_desc(element)`: Lấy content-desc của phần tử
- `get_element_bounds(element)`: Lấy bounds của phần tử
- `is_element_selected(element)`: Kiểm tra xem phần tử có được chọn không

## Yêu cầu

- Python 3.6+
- APK trợ năng đã được cài đặt và chạy trên thiết bị Android
- Thiết bị Android đã bật chế độ gỡ lỗi USB
- Quyền truy cập trợ năng đã được cấp cho APK

## Lưu ý

- Đảm bảo URL của APK trợ năng (base_url) được cấu hình chính xác
- Có thể cần điều chỉnh timeout cho các thiết bị chậm hơn
- Kiểm tra kết nối mạng giữa máy tính và thiết bị Android

## Giấy phép

MIT License 