--==============取得当月设备计数总和================--
declare @enddate varchar(8)
declare @startdate varchar(8)
--declare @checkdate varchar(2)
--set @checkdate='20'
set @enddate='20121220'
set @startdate='20121128'
--select @enddate ,@startdate
insert into printer_km_count_price_history (month,blackext,colorext,mincharge,total,black,color,blackprice,colorprice,colorcharge)
select top 1 @enddate as month,a.Black-p.blackbase as blackext,a.Color-p.colorbase as colorext,p.mincharge,a.*,'0.05' as blackprice,'0.63' as colorprice
,(case when a.color>p.colorbase then (a.Color-p.colorbase)*0.63 When a.Color<p.colorbase then 0 end) as colorcharge
--,(a.Black-p.blackbase)*0.05 as blackcharge
 from printer_km_price p cross join 
(select sum(M.TotalMax-isnull(S.TotalS,0)) as Total,sum(M.BlackMax-isnull(S.BlackS,0)) as Black,sum(M.ColorMax-isnull(S.ColorS,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(Black) as BlackMax,MAX(Color) as ColorMax from printer_km_DeviceCount 
where CreateDate<=@enddate group by DeviceDN) M full outer join
(select DeviceDN,MAX(Total) as TotalS,MAX(Black) as BlackS,MAX(Color) as ColorS from printer_km_DeviceCount
where CreateDate<=@startdate group by DeviceDN) S
on M.DeviceDN=S.DeviceDN
left Join PSESCoreDB.dbo.Device d
on M.DeviceDN=d.DeviceDN) a
where a.Black-p.blackbase>0
order by blackext
---===============Public印量及费用==================--？？？？？？？？？？
declare @startdate varchar(8)
declare @enddate varchar(8)
set @startdate='20121011'
set @enddate='20121128'
select d.DeviceDN,d.Black-ud.Black as pubblack,d.Color-ud.Color as pubcolor
	,(d.Black-ud.Black)*(select blackactualprice from printer_km_count_price_history where MONTH=201211) as blackcharge
	,(d.Color-ud.Color)*0.65 as pubcolor
 from
---------------区间内设备计数器总数--------------------
(select M.DeviceDN,(M.TotalMax-isnull(S.TotalS,0)) as Total,(M.BlackMax-isnull(S.BlackS,0)) as Black,(M.ColorMax-isnull(S.ColorS,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(Black) as BlackMax,MAX(Color) as ColorMax from printer_km_DeviceCount 
where CreateDate<=@enddate group by DeviceDN) M full outer join
(select DeviceDN,MAX(Total) as TotalS,MAX(Black) as BlackS,MAX(Color) as ColorS from printer_km_DeviceCount
where CreateDate<=@startdate group by DeviceDN) S
on M.DeviceDN=S.DeviceDN) d
join
---------------区间内按用户计数的设备印量------------------
(select M.DeviceDN,(M.TotalMax-IsNULL(S.Total,0)) as Total ,(M.BlackMax-ISNULL(S.BlackTotal,0)) as Black
	,(M.ColorMax-ISNULL(S.ColorTotal,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(BlackTotal) as BlackMax,MAX(ColorTotal) as ColorMax from printer_km_DeviceCount_ByUser
where CreateDate<=@enddate
group by DeviceDN) M Full outer join
(select DeviceDN,Max(Total) as Total,max(BlackTotal) as BlackTotal,max(ColorTotal) as ColorTotal from printer_km_DeviceCount_ByUser
where CreateDate<=@startdate 
group by DeviceDN) S
on M.DeviceDN=S.DeviceDN) ud
on  d.DeviceDN=ud.DeviceDN
join PSESCoreDB.dbo.Device od on d.DeviceDN=od.DeviceDN
where od.ManageLevel>0
---===============Public各部门费用==================--
----因无法套用聚合，使用临时表
declare @startdate varchar(8)
declare @enddate varchar(8)
set @startdate='20121011'
set @enddate='20121128'
select od.RegistName,ppc.department,od.SerialNumber,d.DeviceDN,d.Black-ud.Black as pubblack,d.Color-ud.Color as pubcolor
	,(d.Black-ud.Black)*(select blackactualprice from printer_km_count_price_history where MONTH=201211)*ppc.assign as blackcharge
	,(d.Color-ud.Color)*0.65*ppc.assign as colorcharge into #pdp
 from
---------------区间内设备计数器总数--------------------
(select M.DeviceDN,(M.TotalMax-isnull(S.TotalS,0)) as Total,(M.BlackMax-isnull(S.BlackS,0)) as Black,(M.ColorMax-isnull(S.ColorS,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(Black) as BlackMax,MAX(Color) as ColorMax from printer_km_DeviceCount 
where CreateDate<=@enddate group by DeviceDN) M full outer join
(select DeviceDN,MAX(Total) as TotalS,MAX(Black) as BlackS,MAX(Color) as ColorS from printer_km_DeviceCount
where CreateDate<=@startdate group by DeviceDN) S
on M.DeviceDN=S.DeviceDN) d
join
---------------区间内按用户计数的设备印量------------------
(select M.DeviceDN,(M.TotalMax-IsNULL(S.Total,0)) as Total ,(M.BlackMax-ISNULL(S.BlackTotal,0)) as Black
	,(M.ColorMax-ISNULL(S.ColorTotal,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(BlackTotal) as BlackMax,MAX(ColorTotal) as ColorMax from printer_km_DeviceCount_ByUser
where CreateDate<=@enddate
group by DeviceDN) M Full outer join
(select DeviceDN,Max(Total) as Total,max(BlackTotal) as BlackTotal,max(ColorTotal) as ColorTotal from printer_km_DeviceCount_ByUser
where CreateDate<=@startdate 
group by DeviceDN) S
on M.DeviceDN=S.DeviceDN) ud
on  d.DeviceDN=ud.DeviceDN
left join printer_public_assign ppc on d.devicedn=ppc.devicedn
join PSESCoreDB.dbo.Device od on d.DeviceDN=od.DeviceDN
where od.ManageLevel>0
select department,sum(blackcharge) +sum(colorcharge) as publiccharge from #pdp group by department
drop table #pdp
--================================