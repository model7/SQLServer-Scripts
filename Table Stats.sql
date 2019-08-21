/********************************************************************
This script can be used as a template for looping through a data set 
and generating/executing dynamic SQL.

There are definitely some enhancements to required to 
********************************************************************/

/* 1. declare and set variables */

declare
  @tbl varchar(100)
, @col varchar(100) 
, @count int
, @EndCount int
, @RowCount nvarchar(max)
, @ColInfo varchar(2000)
, @sql nvarchar(max)
, @OutputStr nvarchar(max)

set @tbl = <table name> 
set @count = 0

-- set variable used to stop the while loop when finished processing the table
select @EndCount = count(*) from information_schema.columns where table_name = @tbl

-- build first dynamic SQL statement to be executed
select @sql = 'select @RowCount = count(*) from ' + @tbl

/* 2. execute first dynamic SQL statement and return number of rows to be processed (number of columns) */

exec sp_executesql @sql, N'@Rowcount varchar(100) output', @RowCount=@RowCount output

-- set the variable that stores the dynamic 
select @sql=''

/* 4. loop through the columns to get information and generate a pipe delimited data set */

while (@count < @EndCount)
begin
	set @count = @count + 1
	select @col = column_name
	, @ColInfo = '|' + @tbl + '|' + convert(varchar(10), ordinal_position) + '|' + data_type + '|'  
	from information_schema.columns where table_name = @tbl and ordinal_position = @count

	select @sql = 'select @OutputStr= ' + ' isnull(convert(varchar(200), min([' + @col + '])), ''NULL'') +''|'' '
	+ '+ isnull(convert(varchar(200), max([' + @col + '])), ''NULL'') + ''|'' '
	+ '+ isnull(convert(varchar(200), count(distinct [' + @col + '])), ''NULL'') + ''|'' '
	+ '+ isnull(convert(varchar(200), sum(case when [' + @col + '] is null then 1 else 0 end)), ''NULL'') + ''|'' '
	+ '+ convert(varchar(200),' + @RowCount + ') + ''|'' '
	+ ' from ' + @tbl 
	--+ ' where [' + @col + '] is not null' --for testing purposes

 
	exec sp_executesql @sql, N'@OutputStr varchar(100) output', @OutputStr=@OutputStr output

	print @col + @ColInfo + @OutputStr

end
