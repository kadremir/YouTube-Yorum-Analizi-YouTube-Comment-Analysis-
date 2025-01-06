# Gerekli Kütüphaneleri Yükleme
library(httr)
library(dplyr)
library(tidytext)
library(ggplot2)
library(wordcloud)
library(syuzhet)
library(stringr)
library(tidyr)
library(purrr)
library(httpuv)

# API Anahtarı ve OAuth 2.0 Ayarları
options(httr_oauth_cache = TRUE)
client_id <- "YOUR_CLIENT_ID"
client_secret <- "YOUR_CLIENT_SECRET"
api_url <- "https://www.googleapis.com/youtube/v3/"

# OAuth yapılandırması
yt_oauth <- oauth_endpoints("google")
myapp <- oauth_app("google", key = client_id, secret = client_secret)

# Token alma işlemi - genişletilmiş scope'lar ile
token <- oauth2.0_token(
  endpoint = yt_oauth,
  app = myapp,
  scope = c(
    "https://www.googleapis.com/auth/youtube.readonly",
    "https://www.googleapis.com/auth/youtube.force-ssl",
    "https://www.googleapis.com/auth/youtube"
  ),
  cache = TRUE,
  use_oob = FALSE,
  config_init = list(),
  credentials = NULL,
  query_authorize_extra = list(
    access_type = "offline",
    prompt = "consent"
  )
)

# Türkçe stop words listesi oluşturma
turkce_stop_words <- data.frame(
  word = c(
    "ve", "veya", "ile", "için", "bu", "bir", "ben", "sen", "o", "biz", "siz", 
    "onlar", "da", "de", "ki", "mi", "mı", "mu", "mü", "ama", "fakat", "ancak",
    "çünkü", "şu", "şey", "gibi", "hem", "kadar", "daha", "tüm", "en", "sadece",
    "değil", "evet", "hayır", "ya", "yani", "nasıl", "neden", "ne", "niye",
    "hangi", "kim", "nerede", "ne zaman", "çok", "az", "biraz", "fazla"
  ),
  lexicon = "custom"
)

# Dosya yolu (Temp dizini)
output_dir <- "C:/Temp"

# Dizin var mı kontrol et, yoksa oluştur
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Video arama fonksiyonu
search_videos <- function(keyword, token) {
  url <- paste0(
    api_url, "search?",
    "part=snippet&",
    "q=", URLencode(keyword), "&",
    "type=video&",
    "maxResults=50"
  )
  
  response <- GET(url, config(token = token))
  data <- content(response, "parsed")
  
  if (!is.null(data$error)) {
    stop("API Hatası: ", data$error$message)
  }
  
  if (is.null(data$items) || length(data$items) == 0) {
    stop("Videolar bulunamadı. Anahtar kelimeyi kontrol edin.")
  }
  
  video_ids <- lapply(data$items, function(item) {
    if (!is.null(item$id$videoId)) {
      data.frame(
        video_id = item$id$videoId,
        title = item$snippet$title,
        stringsAsFactors = FALSE
      )
    }
  })
  
  video_ids <- do.call(rbind, Filter(Negate(is.null), video_ids))
  print("Bulunan Video ID'leri:")
  print(video_ids$video_id)
  
  return(video_ids)
}

# Yorum alma fonksiyonu
get_video_comments <- function(video_id, token) {
  cat("Video ID işleniyor:", video_id, "\n")
  
  url <- paste0(
    api_url, "commentThreads?",
    "part=snippet&",
    "videoId=", video_id, "&",
    "maxResults=100"
  )
  
  response <- GET(url, config(token = token))
  data <- content(response, "parsed")
  
  if (!is.null(data$error)) {
    message("Yorumlar alınamadı: ", data$error$message)
    return(NULL)
  }
  
  if (is.null(data$items) || length(data$items) == 0) {
    message("Bu video için yorum bulunamadı.")
    return(NULL)
  }
  
  comments <- lapply(data$items, function(item) {
    data.frame(
      text = iconv(
        item$snippet$topLevelComment$snippet$textDisplay,
        from = "UTF-8", to = "UTF-8", sub = ""
      ),
      author = item$snippet$topLevelComment$snippet$authorDisplayName,
      stringsAsFactors = FALSE
    )
  })
  
  comments <- do.call(rbind, comments)
  return(comments)
}

# Yorum analiz fonksiyonu
analyze_comments <- function(comments) {
  clean_comments <- comments %>%
    unnest_tokens(word, text) %>%
    anti_join(turkce_stop_words, by = "word") %>%
    # Sayıları ve tek karakterli kelimeleri temizle
    filter(str_detect(word, "^[a-zA-ZçğıöşüÇĞİÖŞÜ]+$")) %>%
    filter(str_length(word) > 2) %>%
    mutate(word = tolower(word))
  
  word_frequencies <- clean_comments %>%
    count(word, sort = TRUE) %>%
    filter(n > 3)  # En az 3 kez geçen kelimeler
  
  return(word_frequencies)
}

# Görselleştirme fonksiyonu
create_visuals <- function(word_frequencies) {
  # En çok kullanılan kelimelerin bar grafiği
  plot1 <- ggplot(head(word_frequencies, 20), aes(x = reorder(word, n), y = n)) +
    geom_bar(stat = "identity", fill = "#2E86C1", width = 0.7) +
    geom_text(aes(label = n), hjust = -0.2, size = 3.5) +
    coord_flip() +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", margin = margin(b = 20)),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    labs(
      title = "En Sık Kullanılan 20 Kelime",
      x = "Kelimeler",
      y = "Kullanım Sıklığı"
    )
  
  ggsave(file.path(output_dir, "kelime_sikligi.png"), plot = plot1, width = 12, height = 8, dpi = 300)
  
  # Geliştirilmiş kelime bulutu
  png(file.path(output_dir, "kelime_bulutu.png"), width = 1200, height = 800, res = 150)
  set.seed(123)  # Tekrar üretilebilirlik için
  wordcloud(
    words = word_frequencies$word,
    freq = word_frequencies$n,
    min.freq = 3,
    max.words = 100,
    random.order = FALSE,
    rot.per = 0.2,  # Kelimelerin %20'si döndürülsün
    colors = brewer.pal(8, "RdYlBu"),
    scale = c(4, 0.5)  # Kelime boyutları arasındaki farkı artır
  )
  dev.off()
}

# Duygu analizi fonksiyonu
perform_sentiment_analysis <- function(comments) {
  # Basit bir Türkçe duygu sözlüğü oluşturma
  turkce_duygular <- data.frame(
    word = c(
      "güzel", "harika", "muhteşem", "mükemmel", "iyi", "başarılı", "seviyorum",
      "kötü", "berbat", "rezalet", "korkunç", "başarısız", "nefret",
      "üzgün", "mutsuz", "endişeli", "kaygılı", "tedirgin",
      "mutlu", "sevinçli", "heyecanlı", "umutlu"
    ),
    sentiment = c(
      rep("pozitif", 7),
      rep("negatif", 6),
      rep("endişe", 5),
      rep("mutluluk", 4)
    )
  )
  
  sentiments <- comments %>%
    unnest_tokens(word, text) %>%
    anti_join(turkce_stop_words, by = "word") %>%
    inner_join(turkce_duygular, by = "word") %>%
    count(sentiment, sort = TRUE)
  
  # Duygu analizi grafiği
  plot2 <- ggplot(sentiments, aes(x = reorder(sentiment, n), y = n, fill = sentiment)) +
    geom_bar(stat = "identity", width = 0.7) +
    geom_text(aes(label = n), vjust = -0.5, size = 4) +
    scale_fill_brewer(palette = "Set3") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", margin = margin(b = 20)),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      legend.position = "none",
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    labs(
      title = "YouTube Yorumlarında Duygu Analizi",
      x = "Duygular",
      y = "Yorum Sayısı"
    )
  
  ggsave(file.path(output_dir, "duygu_analizi.png"), plot = plot2, width = 10, height = 6, dpi = 300)
}

# Ana çalıştırma kodu
tryCatch({
  # Anahtar kelimeyi belirle
  keyword <- "trend hisse senetleri"  # Anahtar kelimeyi buraya yazın
  
  # 1. Videoları Arama
  video_ids <- search_videos(keyword, token)
  
  if (nrow(video_ids) == 0) {
    stop("Hiç video bulunamadı!")
  }
  
  # 2. Yorumları Çekme - Her video için ayrı ayrı dene
  all_comments <- list()
  for(i in seq_len(nrow(video_ids))) {
    cat("Video işleniyor:", i, "/ ", nrow(video_ids), "\n")
    comments <- get_video_comments(video_ids$video_id[i], token)
    if (!is.null(comments)) {
      all_comments[[length(all_comments) + 1]] <- comments
    }
  }
  
  # Yorumları birleştir
  all_comments <- do.call(rbind, all_comments)
  
  if (is.null(all_comments) || nrow(all_comments) == 0) {
    stop("Hiç yorum bulunamadı!")
  }
  
  # 3. Yorumları Analiz Etme
  word_frequencies <- analyze_comments(all_comments)
  create_visuals(word_frequencies)
  
  # 4. Duygu Analizi
  perform_sentiment_analysis(all_comments)
  
  cat("Analiz tamamlandı. Grafikler kaydedildi!")
}, error = function(e) {
  cat("Hata oluştu:", conditionMessage(e), "\n")
})