create database QLMB
ON PRIMARY (   NAME = 'QuanlyBH',  
 FILENAME = 'T:\ToThanhTan_17102741\QLBH.mdf',
   SIZE = 10MB,  
   FILEGROWTH = 20%,  
   MAXSIZE = 50MB ) 
LOG ON (  NAME = 'QLMB_log', 
    FILENAME = 'T:\ToThanhTan_17102741\QLBH.ldf', 
	 SIZE = 10MB, 
	  FILEGROWTH = 10%, 
	   MAXSIZE = 20MB ) 
--MAYBAY(MaMB, TenMB, Socho):
-- Mỗi máy bay có một mã máy bay duy nhất. Mã máy bay xác định tên máy bay và số chỗ ngồi cho từng máy bay 
-- HoaDon(Makh, NgayBAY, NgayDen, Noidi, NoiDen, MaMB): Mỗi khách hàng có một mã duy nhất, mã khách hàng xác định các thông tin còn lại.  
-- CTHoaDon(MaVe, Makh,  SoVe): Một khách hàng đi trên một chuyến bay có thể mua nhiều vé.
--  Ve(Mave, LoaiVe, DonGia): Mỗi vé có một mã duy nhất. Mã vé xác định các thông tin còn lại.
--   Chú ý loại vé dành cho người lớn sẽ có qui định là một mã vé, trẻ em là một mã, người nước ngoài là một mã,… 
create table MAYBAY
(MaMB int not null primary key,
 TenMB nvarchar , 
 Socho int
)
alter table Maybay add TenMB nvarchar(800)

create table HoaDon
(Makh nvarchar(10) not null primary key,
 Ngaybay datetime, 
 NgayDen datetime,  
 Noidi nvarchar(20),
  NoiDen nvarchar(20),
   MaMB int)

 
create table CTHoaDon
(MaVe int not null ,
 Makh nvarchar(10) , 
  SoVe int
  primary key(MAve,Makh)
)
create table  Ve
(Mave int not null primary key, 
LoaiVe nvarchar(30),
 DonGia Money)
  
 alter table Hoadon add constraint HD_FK  foreign key (MaMB) references Maybay(MaMB)
 alter table CTHoadon add constraint CTHD_FK  foreign key (MaVe) references Ve(Mave)
 alter table CTHoadon add constraint CTHD1_FK  foreign key (Makh) references HOAdon(Makh)

-- • HoaDon: o NgayLapHD >=Ngày hiện hành  (Check constraint) o Giá trị mặc định là ngày hiện hành 
-- (Default constraint) 
--• Sanpham: o Giagoc và SlTong>0 (Check constraint) • 
-- Khachhang: o LoaiKH: bao gồm các giá trị: VIP, TV, VL (Check constraint) 
--CTHOADON 
--3. Số chỗ ngồi nhập trong khoảng từ 20 đến 100. 

alter table Maybay add constraint MB_CK check (20<Socho and Socho<150)
--4. NgayBaylớn hơn hay bằng ngày hiện hành 
alter table Hoadon add constraint HD_ck check (Ngaybay>getdate()) 
--5. Tạo ràng buộc  giá trị mặc định ban đầu cho số chỗ ngồi luôn là 100 
alter table MAybay add constraint MB1_ck default  (100) for Socho
 --6. Thêm vào bảng Vé, một field Thue. Thuế được tự động tính bằng 10% đơn giá.
 alter table Ve add Thue money
 alter table Ve add constraint V_ck default  (0.1*[DonGia]) for Thue
-- Tùy theo mỗi tuyến bay mà đơn giá còn cộng thêm giá phụ thu  

insert into Maybay values (1,100, 'AMP')
insert into Maybay values (2,45, 'BMP')
insert into Maybay values (3,120, 'CMP')
insert into Maybay values (4,100, 'EMP')
select *from MAYBAY


insert into Ve values (1 ,N'Người Lớn', '1000000','')
insert into Ve values (2 ,N'Tre em', '500000','')
insert into Ve values (3 ,N'Nuoc ngoai', '1200000','')
select *from Ve

insert into Hoadon values ('KH01','2018/10/12', '2018/10/12', 'TPHCM ','HUE' ,1 )
insert into Hoadon values ('KH02','2018/10/12', '2018/10/12', 'TPHCM ','HUE' ,1 )
insert into Hoadon values ('KH03','2018/11/02', '2018/11/03', 'Ha Noi','TPHCM' ,2 )
insert into Hoadon values ('KH04','2018/11/02', '2018/11/02', 'Hue','Nha TRang' ,3 )


insert into CTHOadon values (1 ,'KH01', 2)
insert into CTHOadon values (2 ,'KH02', 3)
insert into CTHOadon values (3 ,'KH04', 4)
insert into CTHOadon values (3 ,'KH03', 3)
insert into CTHOadon values (1 ,'KH02', 1)
insert into CTHOadon values (3 ,'KH01', 5)
insert into CTHOadon values ( 1,'KH04', 2)


-- Tạo các Query sau (4 đ) 
-- 1. Liệt kê các chuyến bay từ TP.HCM và HA NOI được sắp  xếp theo MaMb cùng MaMb theo Makh. 
select m.[MaMB],[TenMB],[Makh]
from MAYBAY m join HoaDon h on m.MaMB=h.MaMB
where Noidi like 'TPHCM ' or Noidi like 'Ha Noi'
order by m.MaMB asc

-- 2. Liệt kê danh sách các chuyến bay có MaMB từ 1 đến 3 gồm MaKh, Mamb, SoVe, Dongia, 
-- Thanhtien (Sove * Dongia +Thue+ PhuThu) được sắp xếp theo Makh.
--  PhuThu được tính như sau: Từ Tp.HCM-Hue: 500000, Từ Tp.HCM- HaNoi: 1000000, Từ Tp.HCM-NhaTrang:300000 

select h.MaKh, Mamb, SoVe, Dongia, (Sove * (Dongia +Thue)) as ThanhTien
from Ve v join CTHoaDon ct on v.Mave=ct.MaVe
join HoaDon h on h.Makh=ct.Makh
order by h.Makh asc


--3. Danh sách các khách hàng ứng có tổng số vé lớn hơn 5 
select [Makh], sum(Sove) as Tongve
from CTHoadon
group by Makh
having sum(Sove)>5
--4. Viết query cho biết tổng tiền thu đuợc của từng máy bay. 
select m.[MaMB],[TenMB],[Socho],sum(Sove * (Dongia +Thue)) as ThanhTien
from Ve v join CTHoaDon ct on v.Mave=ct.MaVe join HoaDon h on h.Makh=ct.Makh join MAYBAY m on m.MaMB=h.MaMB
group by m.[MaMB],[TenMB],[Socho]
having sum(Sove * (Dongia +Thue))
  in (select distinct  m.MaMB,sum(Sove * (Dongia +Thue)) as ThanhTien
from Ve v join CTHoaDon ct on v.Mave=ct.MaVe join HoaDon h on h.Makh=ct.Makh join MAYBAY m on m.MaMB=h.MaMB
group by ct.MaVe,h.Makh,v.Mave,m.MaMB
having sum(Sove * (Dongia +Thue))>0
)

--5. Cho biết máy bay nào chưa có khách hàng đăng ký bay viết bằng 3 cách Not In, Left Join và Not Exists 
select [MaMB],[TenMB]
from MAYBAY 
where MaMB not in (select MaMB from HoaDon)

select m.[MaMB],[TenMB]
from MAYBAY m left join HoaDon h   on h.MaMB=m.MaMB
where h.MaMB is null

select m.[MaMB],[TenMB]
from MAYBAY m
where not exists (select m.MaMB 
                            from HoaDon h where m.MaMB=h.MaMB)
							



--6. Tăng đơn giá lên 2% cho những vé của người lớn và nước ngoài, 1% cho vé trẻ em  
CREATE VIEW ten_view AS
SELECT cot1, cot2.....
FROM ten_bang
WHERE [dieu_kien];






