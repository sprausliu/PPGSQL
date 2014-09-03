select d.IPAddress,(dc.Color-dc1.Color) as ColorDiff from
(select M.DeviceDN,(M.TotalMax-isnull(S.TotalS,0)) as Total,(M.BlackMax-isnull(S.BlackS,0)) as Black,(M.ColorMax-isnull(S.ColorS,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(Black) as BlackMax,MAX(Color) as ColorMax from printer_km_DeviceCount 
where CreateDate<=20121120 group by DeviceDN) M full outer join
(select DeviceDN,MAX(Total) as TotalS,MAX(Black) as BlackS,MAX(Color) as ColorS from printer_km_DeviceCount
where CreateDate<=20121118 group by DeviceDN) S
on M.DeviceDN=S.DeviceDN) dc  join
(select M.DeviceDN,(M.TotalMax-IsNULL(S.Total,0)) as Total ,(M.BlackMax-ISNULL(S.BlackTotal,0)) as Black
	,(M.ColorMax-ISNULL(S.ColorTotal,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(BlackTotal) as BlackMax,MAX(ColorTotal) as ColorMax from printer_km_DeviceCount_ByUser
where CreateDate<=20121120
group by DeviceDN) M Full outer join
(select DeviceDN,Max(Total) as Total,max(BlackTotal) as BlackTotal,max(ColorTotal) as ColorTotal from printer_km_DeviceCount_ByUser
where CreateDate<=20121118 
group by DeviceDN) S
on M.DeviceDN=S.DeviceDN) dc1
on dc.DeviceDN=dc1.DeviceDN
left join PSESCoreDB.dbo.Device d on dc.DeviceDN=d.DeviceDN
where dc.Color-dc1.Color<>0