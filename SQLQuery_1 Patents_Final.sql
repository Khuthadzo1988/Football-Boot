
 --The title of a patent can reveal the technical areas in which patent applications are being filed.
 --A count of recurring words in the title column shed light in the areas in which patents are being filed.
 --The count will look at words with more than 3 letters.

 WITH WordCounts AS (
    SELECT
        TRIM(value) AS word
    FROM
        [master].[dbo].[lens-export]
    CROSS APPLY
        STRING_SPLIT(Title, ' ')
    WHERE LEN(TRIM(value)) > 3
 )

 SELECT TOP 100
    word AS TopWord,
    COUNT(*) AS WordCount
 FROM
    WordCounts
 GROUP BY
    word
 ORDER BY
    COUNT(*) DESC;
 ------------------------------------------------------------------------------------------------------------------------------------------------
  --delete column_1, it is a row count column.

  alter table [master].[dbo].[lens-export]
  drop column column_1

 ------------------------------------------------------------------------------------------------------------------------------------------------

 -- determining the total number of applications

 select count(Application_Number) as Total_Applications
 FROM [master].[dbo].[lens-export]

 ------------------------------------------------------------------------------------------------------------------------------------------------
 --Determining the type of patents documents 
 --This will shed light on the break down on granted patents, patent applications etc

 select distinct(Document_Type), count(Document_Type) as Document_Type_Count
 FROM [master].[dbo].[lens-export]
 group by Document_Type

 -----------------------------------------------------------------------------------------------------------------------------------------------
 --legal_status vs count of patent documents vs publication year.
 --This will show which patents are active, expired, Pending etc

 SELECT distinct(Legal_Status), Count(Legal_Status) as Status_Count, Publication_Year
  FROM [master].[dbo].[lens-export]
  group by Legal_Status, Publication_Year
  order by 2 desc

 -----------------------------------------------------------------------------------------------------------------------------------------------

 --split the year from Earliest_Priority_Date to get the priority year.
 --Innovation is secured by a patent from the priority date. 
 --Patents are granted for period of 20 years from the priority date.
 --If you want to know when a patent expires, you need to take the priority date and add 20 years.


 select 
 PARSENAME(Replace(Earliest_Priority_Date, ('-'),('.')), 3)
 FROM [master].[dbo].[lens-export]

 alter TABLE [master].[dbo].[lens-export]
 add Priority_Year int

 UPDATE [master].[dbo].[lens-export]
 set Priority_Year = PARSENAME(Replace(Earliest_Priority_Date, ('-'),('.')), 3)


 -----------------------------------------------------------------------------------------------------------------------------------------------
  --Number of patent publication per country by year
  --This will show the countries with potential for protection based on low numbers.
  
  select Distinct(Publication_Year) as Publications_Per_Year
  , count(Publication_Year) as Published_Patent_Counts, Jurisdiction
  FROM [master].[dbo].[lens-export]
  group by Publication_Year, Jurisdiction
  order by 1 desc

 -------------------------------------------------------------------------------------------------------------------------------------------------------
 --Top patent applicants.
 --This shows the companies most active in the field of football boots/cleat/shoes.

  SELECT DISTINCT(applicants), Count(applicants) as Applicants_Count
  FROM [master].[dbo].[lens-export]
  group by applicants
  order by 2 desc
 
 --Some of the Applicants/Companies have patented via different subsidiaries such as Nike (Subsidiaries: Nike INC, Nike Innovate etc)
 --Applicants name harmonization is needed, harmonization is done to the most common applicants.
 

 SELECT applicants, 
 CASE when applicants like '%NIKE%' then 'NIKE'
      when applicants like '%ADIDAS%' then 'ADIDAS'
      when applicants like '%under armour%' then 'Under Armour'
      when applicants like '%puma%' then 'Puma'
      when applicants like '%Reebok' then 'Reebok'
      when applicants like '%Asics%' then 'Asics'
      when applicants like '%fast ip%' then 'Fast IP'
      when applicants like '%Mizuno%' then 'Mizuno'
      when applicants like '%diadora%' then 'Diadora'
      when applicants like '%vock%' then 'Vock Curtis'
      else applicants
      END
 FROM  [master].[dbo].[lens-export]
 where applicants is not null
 order by 2

 UPDATE [master].[dbo].[lens-export]
 SET applicants =  CASE when applicants like '%NIKE%' then 'NIKE'
      when applicants like '%ADIDAS%' then 'ADIDAS'
      when applicants like '%under armour%' then 'Under Armour'
      when applicants like '%puma%' then 'Puma'
      when applicants like '%Reebok' then 'Reebok'
      when applicants like '%Asics%' then 'Asics'
      when applicants like '%fast ip%' then 'Fast IP'
      when applicants like '%Mizuno%' then 'Mizuno'
      when applicants like '%New balance%' then 'New Balance'
      when applicants like '%diadora%' then 'Diadora'
      when applicants like '%vock%' then 'Vock Curtis'
      else applicants
      END
  
 -------------------------------------------------------------------------------------------------------------------------------------------------------
 --Top owners of patents, some patents are owned by multiple owners
 --Harmonization of owners is needed

 
  select distinct(owners), count (owners) as owner_count
  from  [master].[dbo].[lens-export]
  --order by owner_count DESC
  group by Owners
 order by 2 desc

 SELECT owners, 
 CASE when Owners like '%NIKE%' then 'NIKE'
      when Owners like '%ADIDAS%' then 'ADIDAS'
      when owners like '%under armour%' then 'Under Armour'
      when Owners like '%puma%' then 'Puma'
      when Owners like '%Reebok' then 'Reebok'
      when Owners like '%Asics%' then 'Asics'
      when owners like '%fast ip%' then 'Fast IP'
      when owners like '%Mizuno%' then 'Mizuno'
      when Owners like '%diadora%' then 'Diadora'
      when owners like '%zebra%' then 'Zebra Tech'
      when owners like '%Reebok%' then 'Reebok'
      when owners like '%ACUSH%' then 'Acush'
      when owners like '%fitbit%' then 'fitbit'
      when owners like '%athalonz%' then 'athalonz'
      when owners like '%1169077%' then '1169077 LTD'
      else owners
      END
 FROM  [master].[dbo].[lens-export]
 where owners is not null
 order by 1

 UPDATE [master].[dbo].[lens-export]
 SET owners = CASE when Owners like '%NIKE%' then 'NIKE'
      when Owners like '%ADIDAS%' then 'ADIDAS'
      when owners like '%under armour%' then 'Under Armour'
      when Owners like '%puma%' then 'Puma'
      when Owners like '%Reebok' then 'Reebok'
      when Owners like '%Asics%' then 'Asics'
      when owners like '%fast ip%' then 'Fast IP'
      when owners like '%Mizuno%' then 'Mizuno'
      when applicants like '%New balance%' then 'New Balance'
      when Owners like '%diadora%' then 'Diadora'
      when owners like '%zebra%' then 'Zebra Tech'
      when owners like '%Reebok%' then 'Reebok'
      when owners like '%ACUSH%' then 'Acush'
      when owners like '%fitbit%' then 'fitbit'
      when owners like '%athalonz%' then 'athalonz'
      when owners like '%1169077%' then '1169077 LTD'
      else owners
      END


 -------------------------------------------------------------------------------------------------------------------------------------------------------

 --The top CPC and IPCR classes reprents the fields in which patents are being filed.
 --A classification scheme is a system of codes that groups inventions according to technical area
     --which means similar inventions are grouped under the same classification.
     --One invetion can be classed in more than one class

 --Example of a Main class with its subclasses:
       -- A43  reprents the main class called 'FOOTWEAR' 
       -- A43B  is a subclass of A43 for 'CHARACTERISTIC FEATURES OF FOOTWEAR PARTS OF FOOTWEAR'
       --A43B23/00 is a subclass of A43B about 'Uppers Boot legs Stiffeners Other single parts of footwear'
       --A43B23/02  is a subclass of Uppers Boot legs


 --Using a CTE to split classes and do a count of IPCR Classes

   WITH WordCounts AS (
    SELECT
        TRIM(value) AS word
    FROM
        [master].[dbo].[lens-export]
    CROSS APPLY
        STRING_SPLIT(IPCR_Classifications, ';')
    WHERE LEN(TRIM(value)) > 0
 )

 SELECT TOP 100
    word AS TopWord,
    COUNT(*) AS WordCount
 FROM
    WordCounts
 GROUP BY
    word
 ORDER BY
    COUNT(*) DESC;

 
 --Using a CTE to split classes and do a count of CPC Classes

   WITH WordCounts AS (
    SELECT
        TRIM(value) AS word
    FROM
        [master].[dbo].[lens-export]
    CROSS APPLY
        STRING_SPLIT(CPC_Classifications, ';')
    WHERE LEN(TRIM(value)) > 0
 )

 SELECT TOP 100
    word AS TopWord,
    COUNT(*) AS WordCount
 FROM
    WordCounts
 GROUP BY
    word
 ORDER BY
    COUNT(*) DESC;


 -------------------------------------------------------------------------------------------------------------------------------------------------------
 -- Priority year vs Patent Priority Count 
 -- Patents are normally granted for a duration of 20 years
 -- will look at where patent priority is concentrated to determine the maturity

 SELECT count(Priority_Year) AS Patent_Priority_count, Priority_Year
 FROM  [master].[dbo].[lens-export]--Abstract, unnest(string_to_array(message, ' ')) Abstract  -- implicit LATERAL join
 GROUP  BY Priority_Year--, Title
 ORDER  BY 1 DESC
 
 
 -------------------------------------------------------------------------------------------------------------------------------------------------------
  
