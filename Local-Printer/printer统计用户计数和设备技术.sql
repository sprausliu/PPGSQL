with temp as (select u.UserName,t_user.chinesename,department.d_departname,department.d_finance_class,M.UserDN,(M.TotalMax-IsNULL(S.Total,0)) as Total ,(M.BlackMax-ISNULL(S.BlackTotal,0)) as Black
	,(M.ColorMax-ISNULL(S.ColorTotal,0)) as Color
from
(select UserDN,MAX(Total) as TotalMax,MAX(BlackTotal) as BlackMax,MAX(ColorTotal) as ColorMax from printer_km_UserCount
where CreateDate<='20121119'
group by UserDN) M Full outer join
(select UserDN,Max(Total) as Total,max(BlackTotal) as BlackTotal,max(ColorTotal) as ColorTotal from printer_km_UserCount
where CreateDate<='20121112'
group by UserDN) S 
on M.UserDN=S.UserDN 
left join PSESCoreDB.dbo.ESUser u
on M.UserDN=u.UserDN  
left join t_user on u.UserName=t_user.userid collate SQL_Latin1_General_CP1_CI_AS
left join department on t_user.depart=department.d_id 
WHERE M.TotalMax-IsNULL(S.Total,0)<>0
)


select d.RegistName,M.DeviceDN,(M.TotalMax-isnull(S.TotalS,0)) as Total,(M.BlackMax-isnull(S.BlackS,0)) as Black,(M.ColorMax-isnull(S.ColorS,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(Black) as BlackMax,MAX(Color) as ColorMax from printer_km_DeviceCount 
where CreateDate<=20121130 group by DeviceDN) M full outer join
(select DeviceDN,MAX(Total) as TotalS,MAX(Black) as BlackS,MAX(Color) as ColorS from printer_km_DeviceCount
where CreateDate<=20121101 group by DeviceDN) S
on M.DeviceDN=S.DeviceDN
left Join PSESCoreDB.dbo.Device d
on M.DeviceDN=d.DeviceDN

select d.RegistName,M.DeviceDN,(M.TotalMax-IsNULL(S.Total,0)) as Total ,(M.BlackMax-ISNULL(S.BlackTotal,0)) as Black
	,(M.ColorMax-ISNULL(S.ColorTotal,0)) as Color
from
(select DeviceDN,MAX(Total) as TotalMax,MAX(BlackTotal) as BlackMax,MAX(ColorTotal) as ColorMax from printer_km_DeviceCount_ByUser
where CreateDate<=20121119
group by DeviceDN) M Full outer join
(select DeviceDN,Max(Total) as Total,max(BlackTotal) as BlackTotal,max(ColorTotal) as ColorTotal from printer_km_DeviceCount_ByUser
where CreateDate<=20121112 
group by DeviceDN) S
on M.DeviceDN=S.DeviceDN
left join PSESCoreDB.dbo.Device d
on M.DeviceDN=d.DeviceDN