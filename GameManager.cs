using Godot;
using System;
using System.Collections.Generic;

public partial class GameManager : Node
{
	private static GameManager instance = null;
	public static GameManager Instance
	{
		get
		{
			 if(instance == null)
			 {
				instance = new GameManager();
			 }
			 return instance;
		}
	}

	public List<PlayerData> Players{get; set;} = new List<PlayerData>();

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}

public class PlayerData
{
	public long Id {get; set;}
	public string Name {get; set;}
	public int Score {get; set;}
}