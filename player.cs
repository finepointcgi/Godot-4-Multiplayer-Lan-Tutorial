using Godot;
using System;
using System.Net.WebSockets;

public partial class player : CharacterBody2D
{
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();
	public Vector2 syncPos = new Vector2(0, 0);
	public float syncRot = 0.0f;
	[Export]
	public PackedScene bullet;

	private Node2D gunRotation;
	private Node2D bulletSpawn;

	private MultiplayerSynchronizer multiplayerSynchronizer;
	public override void _Ready()
	{
		gunRotation = GetNode<Node2D>("GunRotation");
		bulletSpawn = GetNode<Node2D>("GunRotation/BulletSpawn");
		multiplayerSynchronizer = GetNode<MultiplayerSynchronizer>("MultiplayerSynchronizer");
		GD.Print($"Parsing {Name}");
		multiplayerSynchronizer.SetMultiplayerAuthority(int.Parse(Name.ToString()));
	}
	public override void _PhysicsProcess(double delta)
	{
		if (multiplayerSynchronizer.GetMultiplayerAuthority() == Multiplayer.GetUniqueId())
		{
			Vector2 velocity = Velocity;

			// Add the gravity.
			if (!IsOnFloor())
				velocity.Y += gravity * (float)delta;

			//Point weapon
			gunRotation.LookAt(GetViewport().GetMousePosition());

			// Handle Jump.
			if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
				velocity.Y = JumpVelocity;

			//Preserve position data
			syncPos = GlobalPosition;
			syncRot = RotationDegrees;

			//Handle firing
			if (Input.IsActionJustPressed("Fire"))
            {
                Rpc("Fire");
            }

            // Get the input direction and handle the movement/deceleration.
            // As good practice, you should replace UI actions with custom gameplay actions.
            var direction = Input.GetAxis("ui_left", "ui_right");
			if (direction == 0.0f)
			{
				velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			}
			else
			{
				velocity.X = direction * Speed;
			}

			Velocity = velocity;
			MoveAndSlide();
		}
		else
		{
			GlobalPosition = GlobalPosition.Lerp(syncPos, .5f);
			RotationDegrees = Mathf.Lerp(RotationDegrees,syncRot, .5f);
		}
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = true)]
	public void Fire()
    {
        var b = bullet.Instantiate<CharacterBody2D>();
        b.GlobalPosition = bulletSpawn.GlobalPosition;
        b.RotationDegrees = gunRotation.RotationDegrees;
        GetTree().Root.AddChild(b);
    }

}
