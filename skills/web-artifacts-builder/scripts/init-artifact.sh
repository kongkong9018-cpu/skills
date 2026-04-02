import requests
from bs4 import BeautifulSoup
from datetime import datetime
import os
import time
import schedule

# 目标网址
URL = "https://www.163.com"

# 请求头，模拟浏览器
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
}

# 保存目录
SAVE_DIR = "data"
os.makedirs(SAVE_DIR, exist_ok=True)


def crawl_webpage():
    try:
        print(f"[{datetime.now()}] 开始爬取: {URL}")

        response = requests.get(URL, headers=HEADERS, timeout=15)
        response.raise_for_status()
        response.encoding = response.apparent_encoding

        soup = BeautifulSoup(response.text, "html.parser")

        # 提取标题
        title = soup.title.string.strip() if soup.title and soup.title.string else "无标题"

        # 提取所有段落
        paragraphs = soup.find_all("p")
        content = "\n".join([p.get_text(strip=True) for p in paragraphs if p.get_text(strip=True)])

        # 文件名按日期保存
        date_str = datetime.now().strftime("%Y-%m-%d")
        file_path = os.path.join(SAVE_DIR, f"{date_str}.txt")

        with open(file_path, "w", encoding="utf-8") as f:
            f.write(f"标题: {title}\n\n")
            f.write("正文内容:\n")
            f.write(content)

        print(f"[{datetime.now()}] 爬取完成，已保存到: {file_path}")

    except Exception as e:
        print(f"[{datetime.now()}] 爬取失败: {e}")


# 每天固定时间执行，例如早上 08:00
schedule.every().day.at("08:00").do(crawl_webpage)

print("定时任务已启动，每天 08:00 自动爬取...")

# 启动时先执行一次（可删）
crawl_webpage()

# 持续运行
while True:
    schedule.run_pending()
    time.sleep(30)
