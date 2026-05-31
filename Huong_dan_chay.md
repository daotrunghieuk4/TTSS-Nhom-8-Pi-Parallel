# HƯỚNG DẪN CHẠY PROJECT TÍNH SỐ PI SONG SONG

## 1. Mục đích của project

Project này dùng để tính gần đúng số Pi bằng phương pháp tích phân số, sau đó so sánh thời gian chạy giữa chương trình tuần tự và chương trình song song.

Project có hai phiên bản chính:

- **Serial**: chương trình tuần tự, chỉ chạy bằng 1 luồng xử lý.
- **OpenMP**: chương trình song song, có thể chạy với 1, 2, 4, 8 thread hoặc nhiều hơn tùy máy.

Kết quả được dùng để so sánh các chỉ số:

- Giá trị Pi tính được.
- Sai số so với Pi tham chiếu.
- Thời gian chạy.
- Speedup.
- Efficiency.

---

## 2. Cấu trúc thư mục quan trọng

```text
TTSS-Nhom-8-main/
├── src/
│   ├── pi_serial.c
│   ├── pi_openmp.c
│   ├── pi_openmp_race_demo.c
│   └── pi_mpi.c
│
├── include/
│   └── pi_common.h
│
├── scripts/
│   ├── benchmark.py
│   ├── benchmark_pair.py
│   ├── run_serial.sh
│   └── run_openmp.sh
│
├── results/
│   └── benchmark_pair_result.csv
│
├── docs/
│   └── HUONG_DAN_CHAY_PROJECT.md
│
└── Makefile
```

Ý nghĩa các file chính:

- `src/pi_serial.c`: code tính Pi tuần tự.
- `src/pi_openmp.c`: code tính Pi song song bằng OpenMP.
- `src/pi_openmp_race_demo.c`: code minh họa lỗi race condition nếu không dùng reduction.
- `include/pi_common.h`: chứa các hàm dùng chung như đo thời gian, đọc tham số, in kết quả.
- `scripts/benchmark.py`: chạy benchmark theo dạng 1 Serial và nhiều cấu hình OpenMP.
- `scripts/benchmark_pair.py`: chạy benchmark theo từng cặp Serial - OpenMP để dễ so sánh thời gian.
- `results/`: lưu file kết quả `.csv`.
- `Makefile`: dùng để biên dịch project nhanh bằng lệnh `make`.

---

## 3. Môi trường chạy

Project được chạy trong môi trường Linux/WSL trên Windows.

Trong VS Code, terminal đúng phải có dạng:

```bash
hieu@DESKTOP:/mnt/c/Users/Admin/Desktop/TTSS-Nhom-8-main$
```

Nếu terminal hiện dạng:

```powershell
PS C:\Users\Admin>
```

thì đó là PowerShell, chưa phải Ubuntu/WSL. Khi đó cần gõ:

```bash
wsl
```

hoặc mở lại folder bằng lựa chọn:

```text
WSL: Reopen Folder in WSL
```

---

## 4. Cài công cụ cần thiết

Nếu máy đã cài rồi thì không cần cài lại. Có thể kiểm tra bằng:

```bash
gcc --version
make --version
python3 --version
unzip -v
```

Nếu thiếu công cụ, chạy:

```bash
sudo apt update
sudo apt install build-essential python3 unzip
```

Trong đó:

- `build-essential`: chứa `gcc` và `make` để biên dịch code C.
- `python3`: dùng để chạy script benchmark.
- `unzip`: dùng để giải nén file project nếu cần.

---

## 5. Vào thư mục project

Nếu project nằm ở Desktop của Windows, có thể vào bằng lệnh:

```bash
cd /mnt/c/Users/Admin/Desktop/TTSS-Nhom-8-main
```

Kiểm tra thư mục hiện tại:

```bash
pwd
```

Kiểm tra các file trong project:

```bash
ls
```

Nếu thấy các thư mục như `src`, `include`, `scripts`, `results`, `docs` và file `Makefile` thì đã vào đúng thư mục project.

---

## 6. Biên dịch project

Chạy lệnh:

```bash
make all
```

Lệnh này sẽ biên dịch hai chương trình chính:

```text
src/pi_serial.c  ->  bin/pi_serial
src/pi_openmp.c  ->  bin/pi_openmp
```

Nếu biên dịch thành công, kiểm tra thư mục `bin`:

```bash
ls bin
```

Kết quả sẽ có:

```text
pi_serial  pi_openmp
```

Nếu trong quá trình biên dịch xuất hiện warning như:

```text
warning: 'parse_int_arg' defined but not used
```

thì không sao. Đây chỉ là cảnh báo, không phải lỗi. Chương trình vẫn chạy bình thường.

---

## 7. Chạy bản Serial

Bản Serial là bản tuần tự, luôn chạy với 1 worker.

Chạy thử với số khoảng chia nhỏ:

```bash
./bin/pi_serial 1000000
```

Chạy với số khoảng chia lớn hơn để đo thời gian:

```bash
./bin/pi_serial 100000000
```

Kết quả có dạng:

```text
mode,N,workers,pi,error,time_sec
serial,100000000,1,3.141592653589793,0.000000000000000e+00,0.123456789
```

Ý nghĩa các cột:

- `mode`: loại chương trình, ở đây là `serial`.
- `N`: số khoảng chia khi tính tích phân.
- `workers`: số worker, với Serial luôn là 1.
- `pi`: giá trị số Pi mà chương trình tính được.
- `error`: sai số so với Pi tham chiếu.
- `time_sec`: thời gian chạy, tính bằng giây.

---

## 8. Chạy bản OpenMP

Bản OpenMP là bản song song, có thể chạy với nhiều thread.

Cú pháp:

```bash
./bin/pi_openmp <N> <so_thread>
```

Ví dụ chạy với 4 thread:

```bash
./bin/pi_openmp 100000000 4
```

Có thể chạy nhiều cấu hình thread khác nhau:

```bash
./bin/pi_openmp 100000000 1
./bin/pi_openmp 100000000 2
./bin/pi_openmp 100000000 4
./bin/pi_openmp 100000000 8
```

Kết quả có dạng:

```text
mode,N,workers,pi,error,time_sec
openmp,100000000,4,3.141592653589793,0.000000000000000e+00,0.045678912
```

Trong đó:

- `workers = 4` nghĩa là OpenMP chạy với 4 thread.
- `time_sec` là thời gian chạy của bản OpenMP.

---

## 9. Chạy benchmark so sánh theo cặp Serial - OpenMP

Đây là cách nên dùng để lấy kết quả cho báo cáo.

Script được sử dụng là:

```bash
scripts/benchmark_pair.py
```

Lệnh chạy:

```bash
python3 scripts/benchmark_pair.py 100000000 3 1,2,4,8
```

Ý nghĩa:

```text
100000000  = số khoảng chia N
3          = mỗi cấu hình chạy 3 lần rồi lấy trung bình
1,2,4,8    = các số thread của OpenMP cần kiểm tra
```

Lệnh trên sẽ tạo 4 cặp so sánh:

```text
Pair 1: Serial vs OpenMP 1 thread
Pair 2: Serial vs OpenMP 2 threads
Pair 3: Serial vs OpenMP 4 threads
Pair 4: Serial vs OpenMP 8 threads
```

Mỗi cặp đều có một lần chạy Serial riêng để so sánh với cấu hình OpenMP tương ứng. Vì vậy, nếu chạy 4 cấu hình OpenMP thì sẽ có 4 dòng kết quả so sánh Serial - OpenMP.

Lưu ý: Serial không có bản 2, 4, 8 thread. Serial luôn là 1 worker. Việc chạy nhiều dòng Serial chỉ nhằm tạo từng cặp so sánh công bằng với từng cấu hình OpenMP.

---

## 10. File kết quả benchmark

Sau khi chạy benchmark pair, kết quả được lưu tại:

```text
results/benchmark_pair_result.csv
```

File này có thể mở bằng Excel hoặc VS Code.

Các cột chính gồm:

```text
pair_id,N,repeat,serial_workers,serial_pi,serial_error,serial_time_sec,serial_time_std,openmp_threads,openmp_pi,openmp_error,openmp_time_sec,openmp_time_std,speedup,efficiency,efficiency_percent,time_saved_sec
```

Ý nghĩa các cột quan trọng:

- `pair_id`: số thứ tự cặp so sánh.
- `N`: số khoảng chia.
- `repeat`: số lần chạy lặp lại để lấy trung bình.
- `serial_workers`: số worker của bản Serial, luôn bằng 1.
- `serial_pi`: giá trị Pi do bản Serial tính được.
- `serial_error`: sai số của bản Serial.
- `serial_time_sec`: thời gian chạy trung bình của Serial.
- `openmp_threads`: số thread của OpenMP.
- `openmp_pi`: giá trị Pi do bản OpenMP tính được.
- `openmp_error`: sai số của bản OpenMP.
- `openmp_time_sec`: thời gian chạy trung bình của OpenMP.
- `speedup`: mức tăng tốc của OpenMP so với Serial.
- `efficiency_percent`: hiệu suất sử dụng thread, tính theo phần trăm.
- `time_saved_sec`: thời gian tiết kiệm được khi dùng OpenMP so với Serial.

---

## 11. Ý nghĩa cột pi

Cột `pi` không phải là số thread.

Cột `pi` là giá trị số Pi mà chương trình tính được bằng công thức tích phân:

```text
pi = ∫[0,1] 4 / (1 + x²) dx
```

Ví dụ:

```text
3.141592653589793
```

Cột này dùng để kiểm tra chương trình tính có đúng không. Nếu cả Serial và OpenMP đều cho giá trị gần `3.1415926535`, nghĩa là thuật toán hoạt động đúng.

Để so sánh tốc độ, cần nhìn các cột:

```text
serial_time_sec
openmp_time_sec
speedup
efficiency_percent
time_saved_sec
```

---

## 12. Công thức tính các chỉ số

### 12.1. Sai số

```text
Error = |pi_computed - pi_reference|
```

Trong đó:

- `pi_computed`: giá trị Pi chương trình tính được.
- `pi_reference`: giá trị Pi tham chiếu.

### 12.2. Speedup

```text
Speedup = T_serial / T_openmp
```

Trong đó:

- `T_serial`: thời gian chạy của bản Serial.
- `T_openmp`: thời gian chạy của bản OpenMP.

Nếu `speedup = 2.5`, nghĩa là OpenMP chạy nhanh hơn Serial khoảng 2.5 lần.

### 12.3. Efficiency

```text
Efficiency = Speedup / số_thread
```

Nếu muốn biểu diễn phần trăm:

```text
Efficiency (%) = Efficiency × 100%
```

---

## 13. Quy trình chạy đề xuất để lấy số liệu báo cáo

Nên chạy theo thứ tự sau:

```bash
cd /mnt/c/Users/Admin/Desktop/TTSS-Nhom-8-main
make clean
make all
./bin/pi_serial 1000000
./bin/pi_openmp 1000000 4
python3 scripts/benchmark_pair.py 100000000 3 1,2,4,8
```

Sau đó mở file:

```text
results/benchmark_pair_result.csv
```

và lấy bảng này đưa vào báo cáo.

---

## 14. Lưu ý khi đo thời gian

Không nên chạy Serial và OpenMP đồng thời thật sự trong cùng một thời điểm, vì hai chương trình sẽ tranh tài nguyên CPU, làm kết quả thời gian bị sai lệch.

Script `benchmark_pair.py` chạy theo cách hợp lý hơn:

```text
Chạy Serial -> đo thời gian -> chạy OpenMP tương ứng -> đo thời gian -> lưu cùng một dòng kết quả
```

Cách này giúp bảng kết quả dễ so sánh nhưng vẫn tránh việc hai chương trình tranh CPU với nhau.

---

## 15. Lệnh quan trọng cần nhớ

Biên dịch:

```bash
make all
```

Chạy Serial:

```bash
./bin/pi_serial 100000000
```

Chạy OpenMP 4 thread:

```bash
./bin/pi_openmp 100000000 4
```

Chạy so sánh theo cặp Serial - OpenMP:

```bash
python3 scripts/benchmark_pair.py 100000000 3 1,2,4,8
```

Mở kết quả:

```text
results/benchmark_pair_result.csv
```
