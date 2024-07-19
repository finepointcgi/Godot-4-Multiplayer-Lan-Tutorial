using Godot;
using System;

public partial class SceneManager : Node2D
{
	[Export]
	public PackedScene PlayerScene;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		for(int i = 0; i<GameManager.Instance.Players.Count; ++i)
		{
			var currentPlayer = PlayerScene.Instantiate<CharacterBody2D>();
			GD.Print($"Setting Name of {i}: {GameManager.Instance.Players[i].Name} {GameManager.Instance.Players[i].Id}");
			currentPlayer.Name = new StringName(GameManager.Instance.Players[i].Id.ToString());
			AddChild(currentPlayer);
			foreach(Node2D spawn in GetTree().GetNodesInGroup("PlayerSpawnPoint"))
			{
				if (spawn.Name == i.ToString())
				{
					currentPlayer.GlobalPosition = spawn.GlobalPosition;
				}
			}
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
