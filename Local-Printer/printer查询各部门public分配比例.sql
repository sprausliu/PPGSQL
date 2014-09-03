/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  p.RegistName,p.IPAddress,d.d_departname,dpa.assign
  FROM [test].[dbo].[printer_public_assign] dpa left join test.dbo.department d on dpa.Department=d.d_id
  left join PSESCoreDB.dbo.Device p on dpa.DeviceDN=p.DeviceDN
