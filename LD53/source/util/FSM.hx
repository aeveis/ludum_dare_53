package util;

/**
 * ...
 * @author aeveis
 */
class FSM
{

	private var currentState:State = null;
	public var current(get, null):EnumValue;
	function get_current() 
	{ 
		if (currentState == null)
		{
			return null;
		}
		else
		{
			return currentState.name; 
		}
	}
	public var last:EnumValue = null;
	public var states:Map<EnumValue,State>;
	public var count:Int = 0;
	public function new() 
	{
		states = new Map();
	}
	
	public function addState(Name:EnumValue, ?EnterFunction:Void->Void, ?UpdateFunction:Void->Void, ?LeaveFunction:Void->Void) 
	{
		var exists:Bool = states.exists(Name);
		var state:State = new State(Name, EnterFunction, UpdateFunction, LeaveFunction);
		states.set(Name, state);
		if (count == 0)
		{
			switchState(Name);
		}
		if (!exists)
		{
			count++;
		}
	}
	
	public function addSequence(Name:EnumValue, ?EnterFunction:Void->Void, ?Events:Array<Void->Bool>)
	{
		var exists:Bool = states.exists(Name);
		var sequence:Sequence = new Sequence(Name, EnterFunction, Events);
		states.set(Name, sequence);
		if (count == 0)
		{
			switchState(Name);
		}
		if (!exists)
		{
			count++;
		}
	}
	
	public function switchState(Name:EnumValue) 
	{
		if (currentState != null) 
		{
			if (currentState.leaveFunction != null) 
			{
				currentState.leaveFunction();
			}
			last = currentState.name;
		} 
		else 
		{
			last = Name;
		}
		currentState = states.get(Name);
		if (currentState.enterFunction != null) 
		{
			currentState.enterFunction();
		}
	}
	
	public function update() 
	{
		if (currentState != null) 
		{
			if (currentState.updateFunction != null) 
			{
				currentState.updateFunction();
			}
		}
	}
}

class State 
{
	public var name:EnumValue;
	public var enterFunction:Void->Void;
	public var updateFunction:Void->Void;
	public var leaveFunction:Void->Void;
	
	public function new(Name:EnumValue, ?EnterFunction:Void->Void, ?UpdateFunction:Void->Void, ?LeaveFunction:Void->Void) 
	{
		name = Name;
		enterFunction = EnterFunction;
		updateFunction = UpdateFunction;
		leaveFunction = LeaveFunction;
	}
	
}

class Sequence extends State 
{
	private var eventIndex:Int = 0;
	private var events:Array<Void->Bool>;
	
	public function new(Name:EnumValue, ?EnterFunction:Void->Void, ?Events:Array<Void->Bool>)
	{
		super(Name, EnterFunction, update, null);
		events = Events;
	}
	public function update()
	{
		if (events != null && eventIndex < events.length)
		{
			if (events[eventIndex]())
			{
				eventIndex++;
			}
		}
	}
}