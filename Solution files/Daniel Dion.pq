let
    Source = Excel.Workbook(File.Contents(FilePath), null, true),
    #"Data Source_Sheet" = Source{[Item="Data Source",Kind="Sheet"]}[Data],
#"Removed Top Rows" = Table.Skip(#"Data Source_Sheet",1),
    #"Removed Bottom Rows" = Table.RemoveLastN(#"Removed Top Rows",8),
    #"Filtered Rows" = Table.SelectRows(#"Removed Bottom Rows", each ([Column1] <> null)),
    #"Added Index" = Table.AddIndexColumn(#"Filtered Rows", "Index", 1, 1),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Index", "Column1", "Column1 - Copy"),
    #"Changed Type" = Table.TransformColumnTypes(#"Duplicated Column",{{"Column1 - Copy", type datetime}}),
    #"Replaced Errors" = Table.ReplaceErrorValues(#"Changed Type", {{"Column1 - Copy", null}}),
    #"Added Custom" = Table.AddColumn(#"Replaced Errors", "Custom", each try(if #"Replaced Errors"[#"Column1 - Copy"]{[Index]}<>null then [Index] else null) otherwise null),
    #"Filled Down1" = Table.FillDown(#"Added Custom",{"Custom"}),
    #"Grouped Rows" = Table.Group(#"Filled Down1", {"Custom"}, {{"Data", each _, type table}}),
    #"Added Custom1" = Table.AddColumn(#"Grouped Rows", "Custom.1", each Table.SelectColumns([Data],{"Column1"})),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Custom.2", each Table.Transpose([Custom.1])),
    #"Expanded Custom.2" = Table.ExpandTableColumn(#"Added Custom2", "Custom.2", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7","Column8","Column9","Column10","Column11","Column12","Column13"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7","Column8","Column9","Column10","Column11","Column12","Column13"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded Custom.2",{"Custom", "Data", "Custom.1"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Column2", "Start Date/Time"}, {"Column4", "Room"}, {"Column1", "Session"}, {"Column5", "Description"}, {"Column6", "Speaker 1"}, {"Column7", "Speaker 2"}, {"Column8", "Speaker 3"}, {"Column9", "Speaker 4"}, {"Column10", "Speaker 5"}, {"Column11", "Speaker 6"}, {"Column12", "Speaker 7"}, {"Column13", "Speaker 8"}}),
    #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns","–","",Replacer.ReplaceText,{"Column3"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Replaced Value",{{"Start Date/Time", type datetime}}),
    #"Inserted Date" = Table.AddColumn(#"Changed Type1", "Date", each DateTime.Date([#"Start Date/Time"]), type date),
    #"Inserted Time" = Table.AddColumn(#"Inserted Date", "Time", each DateTime.Time([#"Start Date/Time"]), type time),
    #"Changed Type2" = Table.TransformColumnTypes(#"Inserted Time",{{"Column3", type time}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Changed Type2",{{"Column3", "End"}, {"Time", "Start"}}),
    #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns1",{"Start Date/Time", "Date", "Start", "End", "Room", "Session", "Description", "Speaker 1", "Speaker 2", "Speaker 3", "Speaker 4", "Speaker 5", "Speaker 6", "Speaker 7", "Speaker 8"})
in
    #"Reordered Columns"