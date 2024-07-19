using Godot;
using System;

public partial class Bullet : CharacterBody2D
{
	public const float Speed = 500.0f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();
	public Vector2 bulletDirection;

    public override void _Ready()
    {
		bulletDirection = new Vector2(1, 0).Rotated(Rotation);
    }
    public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;

		// Add the gravity.
		velocity = Speed * bulletDirection;

		if(! IsOnFloor())
		{
			velocity.Y += (float) (gravity * 1 * delta);
		}
		Velocity = velocity;
		MoveAndSlide();
	}
}
