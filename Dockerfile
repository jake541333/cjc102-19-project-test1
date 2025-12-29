FROM wordpress:6.4-php8.2-fpm

# 安裝 Nginx 與 Supervisor
RUN apt-get update && apt-get install -y nginx supervisor && rm -rf /var/lib/apt/lists/*

# 【關鍵修正 1】清空 Nginx 自動產生的預設檔案
# 確保這個目錄是空的，官方 Entrypoint 才會把 WordPress 搬進來
RUN rm -rf /var/www/html/*
RUN rm -rf /usr/local/etc/php-fpm.d/*
# 強制覆蓋設定檔
COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 移除 Nginx 預設站點
RUN rm -f /etc/nginx/sites-enabled/default

# 【關鍵修正 2】如果你有自訂的 wp-content，建議放到 /usr/src/wordpress
# 這樣啟動時，官方腳本會幫你把核心程式碼和你的內容「合併」到 /var/www/html
COPY wp-content /usr/src/wordpress/wp-content

# 確保權限
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# 使用官方入口腳本，它會幫你處理資料庫連線與 WORDPRESS_CONFIG_EXTRA
ENTRYPOINT ["docker-entrypoint.sh"]

# 最後交給 supervisor 啟動所有進程
CMD /usr/local/bin/docker-entrypoint.sh php-fpm --version && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
