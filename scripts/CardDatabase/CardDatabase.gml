function Card(name_, cost_/*, image_, expansion_, type_, expNumber_, description_, author_, strength_, rarity_*/, id_) constructor
{
	name = name_
	cost = cost_
	id = id_
}

function CSVsToArray()
{
	for (var i = 0; file_exists($"sheet{i}.csv"); i++)
	{
		var csvGrid = load_csv($"sheet{i}.csv")
		var cardAmount = ds_grid_height(csvGrid) - 1
		for (var j = cardAmount; j >= 1; j--)
		{
			var name = csvGrid[# 0, j]
			var cost = csvGrid[# 1, j]
			var id_ = $"{csvGrid[# 3, j]}{csvGrid[# 5, j]}"
			array_push(oInterface.cardDatabase, new Card(name, cost, id_))
			show_debug_message(id_)
		}
	}
}

function DrawCard(id_, x_, y_, scale,)
{
	
}