using Godot;
using System;
using System.Linq;

public partial class MultiplayerController : Control
{
	[Export]
	public string address = "127.0.0.1";
	[Export]
	public int port = 8910;
    private ENetMultiplayerPeer _peer;

	private LineEdit NameLineEdit;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
	{
		NameLineEdit = GetNode<LineEdit>("NameLineEdit");

		Multiplayer.PeerConnected += PeerConnected;
		Multiplayer.PeerDisconnected += PeerDisconnected;
		Multiplayer.ConnectedToServer += ConnectedToServer;
		Multiplayer.ConnectionFailed += ConnectionFailed;
		if(OS.GetCmdlineArgs().Contains("--server"))
		{
			HostGame();
		}
	}

	//called on the server and clients
    private void PeerConnected(long id)
    {
        GD.Print($"Player Connected: {id}");
	}

	//called on the server and clients
    private void PeerDisconnected(long id)
    {
         GD.Print($"Player Disconnected: {id}");
		 var playerToRemove = GameManager.Instance.Players.Where(p=>p.Id == id).FirstOrDefault();
		 GameManager.Instance.Players.Remove(playerToRemove);
		 var players = GetTree().GetNodesInGroup("Player");
		 foreach (var player in players)
		 {
			if(player.Name == id.ToString())	
			{
				player.QueueFree();
			}
		 }
    }


	//called onlyu from clients
    private void ConnectedToServer()
    {
        GD.Print($"Connected to server!");
		RpcId(1, "SendPlayerInformation",NameLineEdit.Text, Multiplayer.GetUniqueId());		
    }

	//called only from clients
    private void ConnectionFailed()
    {
        GD.Print($"Couldn't connect.");
    }

	[Rpc(MultiplayerApi.RpcMode.AnyPeer, CallLocal = false)]
	public void SendPlayerInformation(string name, long id)
	{
		if(!GameManager.Instance.Players.Exists(x => x.Id == id))
		{
			GameManager.Instance.Players.Add(
				new PlayerData(){
					Id = id,
					Name = name,
					Score = 0}
			);
		}
		if(Multiplayer.IsServer())
		{
			foreach(var player in GameManager.Instance.Players)
			{
				Rpc("SendPlayerInformation",player.Name,player.Id);
			}
		}
	}

	[Rpc(MultiplayerApi.RpcMode.AnyPeer,CallLocal = true)]
	public void StartGame()
	{
		var scene = GD.Load<PackedScene>("res://testScene.tscn").Instantiate();
		GetTree().Root.AddChild(scene);
		Hide();
	}

private void HostGame()
{
		_peer = new ENetMultiplayerPeer();
		var error = _peer.CreateServer(port);
		if(error != Error.Ok)
		{
			GD.Print($"Cannot host: {error}");
			return;
		}
		_peer.Host.Compress(ENetConnection.CompressionMode.RangeCoder); //Optional

		Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Waiting for Players.");
}
	public void OnHostButtonDown()
	{
		HostGame();
		SendPlayerInformation(NameLineEdit.Text,Multiplayer.GetUniqueId());
	}

	public void OnJoinButtonDown()
	{
		_peer = new ENetMultiplayerPeer();
		_peer.CreateClient(address,port);
		_peer.Host.Compress(ENetConnection.CompressionMode.RangeCoder); //Optional but must match others
		Multiplayer.MultiplayerPeer = _peer;
	}

	public void OnStartGameButtonDown()
	{
		Rpc("StartGame");
	}
}
