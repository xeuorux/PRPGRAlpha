def fadeOutDarknessBlock(event_id = -1, play_sound = true)
	event_id = 0 if event_id < 0
	event = get_character(event_id)

	if event.name[/DARKBLOCKINVERT/]
		return unless pbGetSelfSwitch(event_id,'A')
		pbSEPlay('fake wall reveal', 150, 100) if play_sound
		toggleSwitch(event_id,'A')
		255.downto(0) do |i|
			next if i % 5 != 0
			event.opacity = i
			pbWait(1)
		end
	else
		return if pbGetSelfSwitch(event_id,'A')
		pbSEPlay('fake wall reveal', 150, 100) if play_sound
		255.downto(0) do |i|
			next if i % 5 != 0
			event.opacity = i
			pbWait(1)
		end
		toggleSwitch(event_id,'A')
	end
end

def fadeInDarknessBlock(event_id = -1, play_sound = true)
	event_id = 0 if event_id < 0
	event = get_character(event_id)
	if event.name[/DARKBLOCKINVERT/]
		return if pbGetSelfSwitch(event_id,'A')
		toggleSwitch(event_id,'A')
		0.upto(255) do |i|
			next if i % 10 != 0
			event.opacity = i
			pbWait(1)
		end
	else
		return unless pbGetSelfSwitch(event_id,'A')
		0.upto(255) do |i|
			next if i % 10 != 0
			event.opacity = i
			pbWait(1)
		end
		toggleSwitch(event_id,'A')
	end
end