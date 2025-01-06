YouTube Yorum Analizi / YouTube Comment Analysis

🤖 Bu kod CURSOR AI yardımıyla oluşturulmuştur. / This code was created with the assistance of CURSOR AI.

English version below
🔍 Türkçe
Bu R projesi, YouTube video yorumlarını analiz eden, kelime sıklıklarını hesaplayan ve duygu analizi yapan kapsamlı bir araçtır. R programlama dilinde çok deneyimim olmamasına rağmen, yapay zeka yardımıyla bu projeyi geliştirdim ve başka başlangıç seviyesindeki geliştiricilere de yardımcı olmasını umuyorum.
🎯 Proje Hakkında
Bu proje, R programlama dilini öğrenme aşamasında olduğum bir dönemde, yapay zeka (Claude AI) yardımıyla geliştirilmiştir. Kod, YouTube API'sini kullanarak yorum analizi yapmayı amaçlamaktadır ve detaylı açıklamalarla birlikte yazılmıştır.
🚀 Özellikler

YouTube API üzerinden video arama
Video yorumlarını toplama
Kelime sıklığı analizi
Görsel analiz (kelime bulutu ve bar grafikleri)
Türkçe yorumlar için duygu analizi
Otomatik görsel raporlama

📋 Gereksinimler
Projeyi çalıştırmak için aşağıdaki R paketlerine ihtiyacınız var:

httr (API istekleri için)
dplyr (veri manipülasyonu)
tidytext (metin analizi)
ggplot2 (görselleştirme)
wordcloud (kelime bulutu oluşturma)
syuzhet (duygu analizi)
stringr (metin işleme)
tidyr (veri düzenleme)
purrr (fonksiyonel programlama)
httpuv (OAuth authentication)

🌱 Başlangıç Seviyesi İçin Notlar
R ile yeni başlayanlar için bazı önemli noktalar:

Paketleri yüklemek için R konsolunda şu komutu kullanın:

RCopyinstall.packages(c("httr", "dplyr", "tidytext", "ggplot2", "wordcloud", "syuzhet", "stringr", "tidyr", "purrr", "httpuv"))

R Studio kullanmanızı öneririm - başlangıç için daha kullanıcı dostu bir arayüz sunar
Hata mesajlarını Google'da aratarak çözüm bulabilirsiniz
Kodun her bölümü yorum satırlarıyla açıklanmıştır

⚠️ Sınırlamalar

YouTube API kotalarına tabidir
Yalnızca herkese açık yorumları analiz edebilir
Şu anda sadece Türkçe dil desteği bulunmaktadır
Başlangıç seviyesinde bir proje olduğu için bazı optimizasyonlar eksik olabilir


🔍 English
This R project is a comprehensive tool that analyzes YouTube video comments, calculates word frequencies, and performs sentiment analysis. Although I don't have much experience in R programming, I developed this project with the help of AI and hope it will help other beginner developers as well.

🎯 About The Project
This project was developed with the assistance of artificial intelligence (Claude AI) while I was in the learning phase of R programming. The code aims to analyze comments using the YouTube API and is written with detailed explanations.

🚀 Features
Video search through YouTube API
Comment collection
Word frequency analysis
Visual analysis (word cloud and bar charts)
Sentiment analysis for Turkish comments
Automatic visual reporting

📋 Requirements
You need the following R packages to run the project:

httr (for API requests)
dplyr (data manipulation)
tidytext (text analysis)
ggplot2 (visualization)
wordcloud (word cloud creation)
syuzhet (sentiment analysis)
stringr (text processing)
tidyr (data organization)
purrr (functional programming)
httpuv (OAuth authentication)

🌱 Notes for Beginners
Important points for R beginners:

Use this command in the R console to install packages:

RCopyinstall.packages(c("httr", "dplyr", "tidytext", "ggplot2", "wordcloud", "syuzhet", "stringr", "tidyr", "purrr", "httpuv"))

I recommend using R Studio - it provides a more user-friendly interface for beginners
You can find solutions by searching error messages on Google
Each section of the code is explained with comments

🔧 Installation

First, create a project from Google Cloud Console and enable YouTube Data API v3
Get your OAuth 2.0 credentials:

Client ID
Client Secret


Download the code and update the client_id and client_secret variables with your credentials

💻 Usage

Before running the code, set the output directory:

RCopyoutput_dir <- "C:/Temp"  # Specify your directory path

Set your search keyword:

RCopykeyword <- "search_term"  # Enter the keyword you want to search

Run the code. The program will automatically:

Search for videos with the specified keyword
Collect comments for each video
Perform word analysis
Create visualizations
Perform sentiment analysis



⚠️ Limitations

Subject to YouTube API quotas
Can only analyze public comments
Currently only supports Turkish language
May lack some optimizations as it's a beginner-level project# YouTube-Yorum-Analizi-YouTube-Comment-Analysis-
