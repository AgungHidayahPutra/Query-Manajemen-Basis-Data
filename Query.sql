-- Menginputkan data ke tabel memesan

DELIMITER //

CREATE PROCEDURE AddToMemesan(
    IN p_id_pembeli VARCHAR(50),
    IN p_id_meja VARCHAR(50),
    IN p_id_pelayan VARCHAR(50),
    IN p_id_menu VARCHAR(50),
    IN p_jml_pesanan INT,
    IN p_total_harga DECIMAL(10, 2)
)
BEGIN
    -- Mulai transaksi
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Gagal menambahkan data ke tabel memesan!';
        END;

        START TRANSACTION;

        BEGIN
            INSERT INTO memesan (id_pembeli, id_meja, id_pelayan, id_menu, jml_pesanan, total_harga)
            VALUES (p_id_pembeli, p_id_meja, p_id_pelayan, p_id_menu, p_jml_pesanan, p_total_harga);

            UPDATE menu
            SET stok = stok - p_jml_pesanan
            WHERE id_menu = p_id_menu;

            COMMIT;
        END;
    END;
END;
//

DELIMITER ;

-- Update status ketersediaan menu setelah stok habis

DELIMITER //

CREATE PROCEDURE UpdateMenuKetersediaan(
    IN p_id_menu VARCHAR(50),
    IN p_ketersediaan ENUM('Tersedia', 'Habis')
)
BEGIN
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Gagal memperbarui status ketersediaan menu!';
        END;

        START TRANSACTION;

        BEGIN
            UPDATE menu
            SET ketersediaan = p_ketersediaan
            WHERE id_menu = p_id_menu;

            COMMIT;
        END;
    END;
END;
//

DELIMITER ;

-- Menambahkan data menu baru

DELIMITER //

CREATE PROCEDURE AddMenu(
    IN p_id_menu VARCHAR(10),
    IN p_nama_menu VARCHAR(50),
    IN p_harga DECIMAL(10,2),
    IN p_kategori VARCHAR(30),
    IN p_ketersediaan ENUM('Tersedia', 'Habis')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Gagal menambahkan menu baru ke tabel menu!';
    END;

    START TRANSACTION;

    BEGIN
        INSERT INTO menu (id_menu, nama_menu, harga, kategori, ketersediaan) 
        VALUES (p_id_menu, p_nama_menu, p_harga, p_kategori, p_ketersediaan);

        COMMIT;
    END;
END;
//

DELIMITER ;

-- Menampilkan menu terlaris berdasarkan jumlah pemesanan

SELECT m.nama_menu, COUNT(ms.id_menu) AS jumlah_terjual 
FROM memesan AS ms 
JOIN menu AS m ON ms.id_menu = m.id_menu 
GROUP BY m.nama_menu 
ORDER BY jumlah_terjual DESC;

-- Menghitung total pendapatan keseluruhan

SELECT SUM(total_harga) AS total_pendapatan 
FROM memesan;

-- Menghitung rata-rata pendapatan per transaksi

SELECT AVG(total_harga) AS rata_pendapatan_per_transaksi 
FROM memesan;

-- Menghitung total jumlah Pesanan Berdasarkan menu

SELECT id_menu, SUM(jml_pesanan) AS total_terjual 
FROM memesan 
GROUP BY id_menu 
ORDER BY total_terjual DESC;

-- Menghitung total pendapatan Berdasarkan menu

SELECT id_menu, SUM(total_harga) AS pendapatan_per_menu 
FROM memesan 
GROUP BY id_menu 
ORDER BY pendapatan_per_menu DESC;

-- Menghitung total pendapatan berdasarkan pelayan

SELECT id_pelayan, SUM(total_harga) AS pendapatan_per_pelayan 
FROM memesan 
GROUP BY id_pelayan 
ORDER BY pendapatan_per_pelayan DESC;

-- Menghitung jumlah transaksi per pembeli

SELECT id_pembeli, COUNT(*) AS jumlah_transaksi 
FROM memesan 
GROUP BY id_pembeli 
ORDER BY jumlah_transaksi DESC;

-- Menampilkan semua menu yang habis

SELECT * FROM menu WHERE ketersediaan = "Habis";

-- Menampilkan data pelayan dengan gaji di atas nilai tertentu

SELECT * FROM pelayan WHERE gaji > #####;