-- 1. VIEW KULLANIMI: Aktif olarak yatan hastaları ve sorumlu doktorlarını getiren sanal tablo
CREATE OR REPLACE VIEW v_aktif_yatan_hastalar AS
SELECT 
    h.tc_no,
    CONCAT(h.ad, ' ', h.soyad) AS hasta_ad_soyad,
    o.oda_no,
    CONCAT(d.unvan, ' ', d.ad, ' ', d.soyad) AS sorumlu_doktor,
    y.yatma_tarihi,
    DATEDIFF(CURRENT_DATE, y.yatma_tarihi) AS yatis_suresi_gun
FROM yatislar y
JOIN hastalar h ON y.hasta_id = h.id
JOIN odalar o ON y.oda_id = o.id
JOIN doktorlar d ON y.sorumlu_doktor_id = d.id
WHERE y.cikis_tarihi IS NULL;

-- 2. AGGREGATION & CASE WHEN: Branşlara göre randevu istatistikleri ve onaylanma oranları
SELECT 
    b.ad AS brans_adi,
    COUNT(r.id) AS toplam_randevu,
    SUM(CASE WHEN r.durum = 'onaylandı' THEN 1 ELSE 0 END) AS onaylanan_randevu,
    SUM(CASE WHEN r.durum = 'iptal' THEN 1 ELSE 0 END) AS iptal_randevu,
    ROUND((SUM(CASE WHEN r.durum = 'onaylandı' THEN 1 ELSE 0 END) / COUNT(r.id)) * 100, 2) AS onay_orani_yuzde
FROM randevular r
JOIN poliklinikler p ON r.poliklinik_id = p.id
JOIN branslar b ON p.brans_id = b.id
GROUP BY b.id, b.ad
ORDER BY toplam_randevu DESC;

-- 3. SUBQUERY & HAVING: Son 6 ayda acil servise 3'ten fazla gelen riskli hastaların tespiti
SELECT 
    h.tc_no,
    h.ad,
    h.soyad,
    COUNT(a.id) AS acil_gelis_sayisi,
    MAX(a.gelis_saati) AS son_gelis_tarihi
FROM acil_servis a
JOIN hastalar h ON a.hasta_id = h.id
WHERE a.gelis_saati >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
GROUP BY h.id, h.tc_no, h.ad, h.soyad
HAVING COUNT(a.id) >= 3
ORDER BY acil_gelis_sayisi DESC;
