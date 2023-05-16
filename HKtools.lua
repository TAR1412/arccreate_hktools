

addFolder(nil, "hk.tools", "HK tools")



--e41c
addMacroWithIcon("hk.tools", "hk.tools.straightenarc", "Straighten arc", "e41c",

    function ()
	
	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc"
    )
    coroutine.yield()
	local arc = arcRequest.result["arc"][1]
	
	if (arc.timing == arc.endTiming) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("Your arc length must not be zero!"),
	})
		
		else
	    local batchCommand = Command.create("Straighten arc (hk.tools)")
        batchCommand.add(
            Event.arc(
                arc.timing,
				arc.startXY,
                arc.endTiming,
				arc.startXY,
                arc.isVoid,
                arc.color,
                's',
                arc.timingGroup
			).save()
		)
				
        batchCommand.add(arc.delete())
		batchCommand.commit();
		end
	
end	
)


addMacroWithIcon("hk.tools", "hk.tools.arcconnect", "Arc Connect", "e157",

    function ()
	
	local arcRequest1 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the first arc"
    )
    coroutine.yield()
	local arcRequest2 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the second arc"
    )
    coroutine.yield()
	
	local arc1 = arcRequest1.result["arc"][1]
	local arc2 = arcRequest2.result["arc"][1]
	
    --[[DialogInput.withTitle("Hee").requestInput({
        DialogField.create("1").description("Hee Yai "..tostring(arc.startXY).."\n"..tostring(arc.endTiming)),
    })	]]--
	    local batchCommand = Command.create("Arc connect (hk.tools)")
        if (arc2.timing >= arc1.endTiming) then
		batchCommand.add(
            Event.arc(
                arc1.endTiming,
				arc1.endXY,
                arc2.timing,
				arc2.startXY,
                arc1.isVoid,
                arc1.color,
                's',
                arc1.timingGroup
			).save()
		)
		else
		DialogInput.withTitle("Error!").requestInput({
        DialogField.create("1").description("Your first arc end is later than the second arc start\n(Cannot generate negative arc length)"),
		})
		end	
		batchCommand.commit();
		if ((arc2.timing-arc1.endTiming) < 10 and (arc2.timing-arc1.endTiming) > 0) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("Your connected arc length is too short (<10 ms)\nPlease check your arc again"),
		})
		
		end
	
	end
		
)


addFolderWithIcon("hk.tools", "hk.tools.arctools", "e922", "Arc tools (7)")

addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.splitarc", "Split arc", "e14e", function()

	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc"
    )
    coroutine.yield()
	local arc = arcRequest.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc.timing) / Context.beatlineDensity
	local n = arc.timing
	local arcEndTim
	local cmd = Command.create("Split arc (hk.tools)")
	while (n< (arc.endTiming)) do
	if ((n+interval) <= arc.endTiming) then
	arcEndTim = n+interval
	else
	arcEndTim = arc.endTiming
	end
	
	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            arc.positionAt(n),
            arcEndTim,
            arc.positionAt(arcEndTim),
            arc.isVoid,
            arc.color,
            's',
            arc.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	n = n + interval
	end
	cmd.add(arc.delete())
	cmd.commit();

end
)


addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.splitarcamyg", "Split arc (with height line)", "e14e", function()

	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc"
    )
    coroutine.yield()
	local arc = arcRequest.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc.timing) / Context.beatlineDensity
	local n = arc.timing
	local startpos, endpos
	local i = 1
	local arcEndTim
	local a,b



	
	local cmd = Command.create("Split arc (hk.tools)")
	while (n< (arc.endTiming)) do
	if ((n+interval) <= arc.endTiming) then
	arcEndTim = n+interval
	else
	arcEndTim = arc.endTiming
	end
	

	startpos 	= arc.positionAt(n)
	endpos 		= arc.positionAt(arcEndTim)
	
	if (i == 1) then
	a = 0
	b = 0.01
	else
	a = 0.01
	b = 0
	end
	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            xy(startpos.x,startpos.y-a),
            arcEndTim,
            xy(endpos.x,endpos.y-b),
            arc.isVoid,
            arc.color,
            's',
            arc.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	i = i*(-1)
	n = n + interval
	end
	cmd.add(arc.delete())
	cmd.commit();

end
)


addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.pianoarc", "Piano arc", "e521", function()

	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc"
    )
    coroutine.yield()
	
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
		DialogField.create("l").setLabel("Length multiplier").defaultTo('1.0').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	
	local length = dialogRequest.result["l"]+0.0
	
	local arc = arcRequest.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc.timing) / Context.beatlineDensity
	local n = arc.timing
	local arcEndTim
	local cmd = Command.create("Piano arc (hk.tools)")
	while (n< (arc.endTiming)) do
	if ((n+interval) <= arc.endTiming) then
	arcEndTim = (n+interval*length)
	else
	arcEndTim = arc.endTiming
	end
	
	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            arc.positionAt(n),
            arcEndTim,
            arc.positionAt(n),
            arc.isVoid,
            arc.color,
            's',
            arc.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	n = n + interval
	end
	cmd.add(arc.delete())
	cmd.commit();

end
)


addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.stair", "Stair arc", "f1a9", function()

	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc"
    )
    coroutine.yield()
	
	
	local arc = arcRequest.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc.timing) / Context.beatlineDensity
	local n = arc.timing
	local arcEndTim
	local cmd = Command.create("Stair arc (hk.tools)")
	while (n< (arc.endTiming)) do
	if ((n+interval) <= arc.endTiming) then
	arcEndTim = (n+interval)
	else
	arcEndTim = arc.endTiming
	end
	
	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            arc.positionAt(n),
            arcEndTim,
            arc.positionAt(n),
            arc.isVoid,
            arc.color,
            's',
            arc.timingGroup
        ).save()
		
    )
	cmd.add(
        Event.arc(
            arcEndTim,
            arc.positionAt(n),
            arcEndTim,
            arc.positionAt(arcEndTim),
            arc.isVoid,
            arc.color,
            's',
            arc.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	n = n + interval
	end
	cmd.add(arc.delete())
	cmd.commit();

end
)


addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.zigzagarc", "Zigzag arc", "e6e1", 
function()

	local arcRequest1 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the main arc"
    )
    coroutine.yield()
	local arcRequest2 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the second arc"
    )
    coroutine.yield()
	local arc1 = arcRequest1.result["arc"][1]
	local arc2 = arcRequest2.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc1.timing) / Context.beatlineDensity
	local n = arc1.timing
	local startpos, endpos
	local i = 1
	local arcEndTim
	local a,b



	
	local cmd = Command.create("Zigzag arc (hk.tools)")
	
	
	
	while (n< (arc1.endTiming)) do
	if ((n+interval) <= arc1.endTiming) then
	arcEndTim = n+interval
	else
	arcEndTim = arc1.endTiming
	end
	

	
	if (i == 1) then
	a = 0
	b = 0.01
	startpos 	= arc1.positionAt(n)
	endpos 		= arc2.positionAt(arcEndTim)
	else
	a = 0.01
	b = 0
	startpos 	= arc2.positionAt(n)
	endpos 		= arc1.positionAt(arcEndTim)
	end
	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            xy(startpos.x,startpos.y-a),
            arcEndTim,
            xy(endpos.x,endpos.y-b),
            arc1.isVoid,
            arc1.color,
            's',
            arc1.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	i = i*(-1)
	n = n + interval
	end
	cmd.add(arc1.delete())
	cmd.add(arc2.delete())
	cmd.commit();


end
)

addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.ranarc", "World Ender arc (ran arc)", "e6e1", 
function()

	local arcRequest1 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the main arc"
    )
    coroutine.yield()
	local arcRequest2 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the second arc"
    )
    coroutine.yield()
	local arc1 = arcRequest1.result["arc"][1]
	local arc2 = arcRequest2.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc1.timing) / Context.beatlineDensity
	local n = arc1.timing
	local startpos, endpos
	local i = 1
	local arcEndTim
	local a,b



	
	local cmd = Command.create("World Ender arc (hk.tools)")
	
	
	
	while (n< (arc1.endTiming)) do
	if ((n+interval) <= arc1.endTiming) then
	arcEndTim = n+interval
	else
	arcEndTim = arc1.endTiming
	end
	
	startpos 	= arc1.positionAt(n)
	endpos 		= arc2.positionAt(arcEndTim)
	

	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            xy(startpos.x,startpos.y),
            arcEndTim,
            xy(endpos.x,endpos.y),
            arc1.isVoid,
            arc1.color,
            's',
            arc1.timingGroup
        ).save()
		
    )
	cmd.add(
        Event.arc(
            arcEndTim,
            arc2.positionAt(arcEndTim),
            arcEndTim,
            arc1.positionAt(arcEndTim),
            arc1.isVoid,
            arc1.color,
            's',
            arc1.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	i = i*(-1)
	n = n + interval
	end
	cmd.add(arc1.delete())
	cmd.add(arc2.delete())
	cmd.commit();



end
)


addMacroWithIcon("hk.tools.arctools", "hk.tools.arctools.seventharc", "7th Sense arc", "e6e1", 
function()

local arcRequest1 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the main arc"
    )
    coroutine.yield()
	local arcRequest2 = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the second arc"
    )
    coroutine.yield()
	local arc1 = arcRequest1.result["arc"][1]
	local arc2 = arcRequest2.result["arc"][1]
	local interval 	= Context.beatLengthAt(arc1.timing) / Context.beatlineDensity
	local n = arc1.timing
	local startpos, endpos
	local i = 1
	local arcEndTim
	local a,b



	
	local cmd = Command.create("7th Sense arc (hk.tools)")
	
	
	
	while (n< (arc1.endTiming)) do
	if ((n+interval) <= arc1.endTiming) then
	arcEndTim = n+interval
	else
	arcEndTim = arc1.endTiming
	end
	
	startpos 	= arc1.positionAt(n)
	endpos 		= arc2.positionAt(arcEndTim)

	if (arcEndTim-n>1)then
	cmd.add(
        Event.arc(
            n,
            xy(startpos.x,startpos.y),
            arcEndTim,
            xy(endpos.x,endpos.y),
            arc1.isVoid,
            arc1.color,
            's',
            arc1.timingGroup
        ).save()
		
    )
	end
	if (arcEndTim-n <= 10 and arcEndTim-n >1) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("There is < 10 ms arc in your arc chain \nplease check"),
		})
	end
	i = i*(-1)
	n = n + interval
	end
	cmd.add(arc1.delete())
	cmd.add(arc2.delete())
	cmd.commit();

end
)


addMacroWithIcon("hk.tools", "hk.tools.arcshift", "Arc shift (Individual)", "e56b",

    function ()
	local arc = {}
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("num").setLabel("Num").defaultTo('8').setTooltip('How many arc you want to shift?').textField(FieldConstraint.create().integer()),
		DialogField.create("x").setLabel("X shift").defaultTo('0.0').setTooltip('(+) = Right, (-) = Left').textField(FieldConstraint.create().float()),
		DialogField.create("y").setLabel("Y shift").defaultTo('0.0').setTooltip('(+) = Up, (-) = Down').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	
	local n 	= dialogRequest.result["num"]+0
	local dx 	= dialogRequest.result["x"]+0.0
	local dy 	= dialogRequest.result["y"]+0.0	
	local cmd 	=  {}
	local arcRequest
	while (n>0) do
	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc ( "..tostring(n).." arcs left)"
    )
	coroutine.yield()
	cmd[n] = Command.create("Arc shift (hk.tools)")
	arc[n] = arcRequest.result["arc"][1]
	cmd[n].add(
        Event.arc(
            arc[n].timing,
            xy(arc[n].startXY.x+dx, arc[n].startXY.y+dy),
            arc[n].endTiming,
            xy(arc[n].endXY.x+dx, arc[n].endXY.y+dy),
            arc[n].isVoid,
            arc[n].color,
            arc[n].type,
            Context.currentTimingGroup
        ).save()
    )
	cmd[n].add(arc[n].delete())
	cmd[n].commit();
	n=n-1
	end
	
	
end
)

addMacroWithIcon("hk.tools", "hk.tools.arcshift2", "Arc shift (Selection)", "e56b",

    function ()

	local selectionInput = EventSelectionInput.requestEvents(
			EventSelectionConstraint.create().arc(),
			"Select the arcs > Then press enter"
    )
	  --requestInput code above
	coroutine.yield()
	local cmd = Command.create("Arc shift (hk.tools)")
	local arc = {}
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
		DialogField.create("x").setLabel("X shift").defaultTo('0.0').setTooltip('(+) = Right, (-) = Left').textField(FieldConstraint.create().float()),
		DialogField.create("y").setLabel("Y shift").defaultTo('0.0').setTooltip('(+) = Up, (-) = Down').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()

	local dx 	= dialogRequest.result["x"]+0.0
	local dy 	= dialogRequest.result["y"]+0.0	
	
	for n = 1, #selectionInput.result["arc"], 1 do
	arc[n] = selectionInput.result["arc"][n]
	
		cmd.add(
            Event.arc(
                arc[n].timing,
				xy(arc[n].startXY.x + dx,arc[n].startXY.y + dy),
                arc[n].endTiming,
				xy(arc[n].endXY.x + dx,arc[n].endXY.y + dy),
                arc[n].isVoid,
                arc[n].color,
                arc[n].type,
                arc[n].timingGroup
			).save()
		)
				
        cmd.add(arc[n].delete())
	end
	
	

	

		cmd.commit();
	

end
)

addMacroWithIcon("hk.tools", "hk.tools.freearctap", "Free arctap", "f07e",

    function ()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select timing")
    coroutine.yield()

    local tim = startTimingRequest.result["timing"]

    local positionRequest = TrackInput.requestPosition(tim, "Select position")
    coroutine.yield()

    local pos = positionRequest.result["xy"]
	
	    local batchCommand = Command.create("Free arctap (hk.tools)")
        local arc = Event.arc(
                tim,
				pos,
                tim+1,
				pos,
                true,
                0,
                's',
                Context.currentTimingGroup
			)
		batchCommand.add(arc.save())
		batchCommand.add(
            Event.arctap(
                tim,
                arc
            ).save()
        )
		batchCommand.commit();
	
	end
		
	)

addMacroWithIcon("hk.tools", "hk.tools.taptoarctap", "Tap to Free arctap", "e0d5",

    function ()
	
	local tapRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().tap(),
        "Select the tap"
    )
    coroutine.yield()
	local tap = tapRequest.result["tap"][1]
	

	local batchCommand = Command.create("Tap to Free arctap(hk.tools)")
	
	
        local arc = Event.arc(
               tap.timing,
				xy(tap.lane/2-0.75,0),
                tap.timing+1,
				xy(tap.lane/2-0.75,0),
                true,
                0,
                's',
                Context.currentTimingGroup
			)
		batchCommand.add(arc.save())
		batchCommand.add(
            Event.arctap(
                tap.timing,
                arc
            ).save()
        )

	batchCommand.add(tap.delete())	
	batchCommand.commit();
	
	
	
end
)
	
	
	
	
	
	

--- FUNCTIONS ---

function depth_box (t1, t2, a, b, tg, isHold) 
	local cmd = Command.create("")
	cmd.add(
        Event.arc(
            t1,
            xy(a, -0.2),
            t2,
            xy(a, -0.2),
            true,
            0,
            's',
            tg
        ).save()
		
    )
	cmd.add(
        Event.arc(
            t1,
            xy(b, -0.2),
            t2,
            xy(b, -0.2),
            true,
            0,
            's',
            tg
        ).save()
    )
	cmd.add(
        Event.arc(
            t1,
            xy(a, -0.2),
            t1,
            xy(b, -0.2),
            true,
            0,
            's',
            tg
        ).save()
    )
	cmd.add(
        Event.arc(
            t2,
            xy(a, -0.2),
            t2,
            xy(b, -0.2),
            true,
            0,
            's',
            tg
        ).save()
    )
	

	if (isHold == 'y') then
        cmd.add( Event.arc(
            t1,
            xy((a+b)/2, -0.2),
            t2,
            xy((a+b)/2, -0.2),
            true,
            0,
            's',
            tg
        ).save()
    )
		
	end
	cmd.commit();
end


function arctotrace(tS, posS, tE, posE, color, arctype, tg)
		
		local cmd = Command.create("")
		cmd.add(
			Event.arc(
				tS,
				posS,
				tE,
				posE,
				true,
				color,
				arctype,
				tg
				).save()
				)
		cmd.commit();
end



function arctotraceGen (arc)

		local cmd = Command.create("")
		-- TOP --
		cmd.add(
			Event.arc(
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y+0.1), 
			arc.endTiming, 	xy(arc.endXY.x, arc.endXY.y + 0.1), 
			true, 0, arc.type, arc.timingGroup).save())
		
		--[[ BOTTOM --
		cmd.add(
		Event.arc(
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y-0.15), 
			arc.endTiming, 	xy(arc.endXY.x, arc.endXY.y - 0.15), 
			true, 0, arc.type, arc.timingGroup).save())
]]--Remove comment if you want to keep bottom line (It's extremely messy tho)			
			
		-- LEFT --
		cmd.add(Event.arc(
			arc.timing , 	xy(arc.startXY.x-0.1,arc.startXY.y-0.07), 
			arc.endTiming, 	xy(arc.endXY.x-0.1, arc.endXY.y - 0.07), 
			true, 0, arc.type, arc.timingGroup).save())
		-- RIGHT --
		cmd.add(Event.arc(
			arc.timing , 	xy(arc.startXY.x+0.1,arc.startXY.y-0.07), 
			arc.endTiming, 	xy(arc.endXY.x+0.1, arc.endXY.y - 0.07), 
			true, 0, arc.type, arc.timingGroup).save())
		
		-- FACE CAP --
		cmd.add(Event.arc(
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y+0.1), 
			arc.timing , 	xy(arc.startXY.x+0.1,arc.startXY.y-0.07),  
			true, 0, 's', arc.timingGroup).save())	
		cmd.add(Event.arc(
			arc.timing , 	xy(arc.startXY.x+0.1,arc.startXY.y-0.07),  
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y-0.15), 
			true, 0, 's', arc.timingGroup).save())
		cmd.add(Event.arc(
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y-0.15), 
			arc.timing , 	xy(arc.startXY.x-0.1,arc.startXY.y-0.07), 			
			true, 0, 's', arc.timingGroup).save())
		cmd.add(Event.arc( 
			arc.timing , 	xy(arc.startXY.x-0.1,arc.startXY.y-0.07),
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y+0.1),
			true, 0, 's', arc.timingGroup).save())					
		
		-- END CAP --
		cmd.add(Event.arc(
			arc.endTiming, 	xy(arc.endXY.x, arc.endXY.y + 0.1), 
			arc.endTiming, 	xy(arc.endXY.x+0.1, arc.endXY.y - 0.07),
			true, 0, arc.type, arc.timingGroup).save())
		
		cmd.add(Event.arc(
			arc.endTiming, 	xy(arc.endXY.x+0.1, arc.endXY.y - 0.07),
			arc.endTiming, 	xy(arc.endXY.x, arc.endXY.y - 0.15), 
			true, 0, arc.type, arc.timingGroup).save())
		cmd.add(Event.arc(
			arc.endTiming, 	xy(arc.endXY.x, arc.endXY.y - 0.15), 
			arc.endTiming, 	xy(arc.endXY.x-0.1, arc.endXY.y - 0.07), 
			true, 0, arc.type, arc.timingGroup).save())	
		cmd.add(Event.arc(
			arc.endTiming, 	xy(arc.endXY.x-0.1, arc.endXY.y - 0.07), 
			arc.endTiming, 	xy(arc.endXY.x, arc.endXY.y + 0.1),
			true, 0, arc.type, arc.timingGroup).save())	
		
		-- VERTICAL LINE --
		cmd.add(Event.arc(
			arc.timing , 	xy(arc.startXY.x,arc.startXY.y-0.15), 
			arc.timing, 	xy(arc.startXY.x, -0.2), 
			true, 0, arc.type, arc.timingGroup).save())

		
		
		
		
		cmd.commit();


end




--- CONVERT TO TRACE ---

addFolderWithIcon("hk.tools", "hk.tools.totrace", "e028", "Convert to traces (5)")

addMacroWithIcon("hk.tools.totrace", "hk.tools.totrace.taptotrace", "Tap to trace", "e5da", function()

	local tapRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().tap(),
        "Select the tap"
    )
    coroutine.yield()
	local tap = tapRequest.result["tap"][1]
	
	local depth = 15 -->THIS MUST BE ABLE TO CUSTOMIZE
	local batchCommand = Command.create("Tap to trace (hk.tools)")
	
	depth_box (tap.timing, tap.timing+depth, tap.lane/2-0.975, tap.lane/2-0.525, tap.timingGroup, 'n')
	batchCommand.add(tap.delete())	
	batchCommand.commit();
	
end
)
addMacroWithIcon("hk.tools.totrace", "hk.tools.totrace.holdtotrace", "Hold to trace", "e5da",function()

	local holdRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().hold(),
        "Select the hold"
    )
    coroutine.yield()
	local hold = holdRequest.result["hold"][1]
	

	local batchCommand = Command.create("Hold to trace (hk.tools)")
	arc = depth_box (hold.timing, hold.endTiming, hold.lane/2-0.975, hold.lane/2-0.525, hold.timingGroup, 'y')
	batchCommand.add(hold.delete())	
	batchCommand.commit();
	
end
)


addMacroWithIcon("hk.tools.totrace", "hk.tools.totrace.arctotrace", "Arc to trace", "e5da", function()

	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the arc"
    )
    coroutine.yield()
	local arc = arcRequest.result["arc"][1]
	
	
	if (arc.isVoid == true) then
	DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("The arc must not be trace"),
    })
	else
	arctotraceGen (arc)
	local cmd = Command.create("")
	cmd.add(arc.delete())
	cmd.commit();
	end

end
)

addMacroWithIcon("hk.tools.totrace", "hk.tools.totrace.freearctapbox", "Arctap box (Free)", "e5da", function()

	local startTimingRequest = TrackInput.requestTiming(true, "Select timing")
    coroutine.yield()

    local t = startTimingRequest.result["timing"]

    local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()

    local pos = positionRequest.result["xy"]
	local depth = 15 -->THIS MUST BE ABLE TO CUSTOMIZE
	local cmd = Command.create("Arctap box (hk.tools)")

		-- UP --
		cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y),
            t,
            xy(pos.x+0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- DOWN --
		cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y-0.12),
            t,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- LEFT --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y),
            t,
            xy(pos.x-0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
		-- RIGHT --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x+0.25, pos.y),
            t,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	
	-- UL --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y),
            t+depth,
            xy(pos.x-0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- UR --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x+0.25, pos.y),
            t+depth,
            xy(pos.x+0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- DL --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y-0.12),
            t+depth,
            xy(pos.x-0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- DR --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x+0.25, pos.y-0.12),
            t+depth,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )	
	
	-- BACK SIDE --
		-- UP --
		cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x-0.25, pos.y),
            t+depth,
            xy(pos.x+0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- DOWN --
		cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x-0.25, pos.y-0.12),
            t+depth,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- LEFT --
	cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x-0.25, pos.y),
            t+depth,
            xy(pos.x-0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
		-- RIGHT --
	cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x+0.25, pos.y),
            t+depth,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )	
		cmd.commit();
end
)


addMacroWithIcon("hk.tools.totrace", "hk.tools.totrace.arctapbox", "Arctap box (On trace)", "e5da", function()

	local arcRequest = EventSelectionInput.requestSingleEvent(
        EventSelectionConstraint.create().arc(),
        "Select the trace"
    )
    coroutine.yield()
	local arc = arcRequest.result["arc"][1]
	
	
	if (arc.isVoid == false) then
	DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("The arc must be trace"),
    })
	else

	local startTimingRequest = TrackInput.requestTiming(true, "Select timing")
    coroutine.yield()

    local t = startTimingRequest.result["timing"]

    local pos = arc.positionAt(t)
	local depth = 15 -->THIS MUST BE ABLE TO CUSTOMIZE
	local cmd = Command.create("Arctap box (hk.tools)")

		-- UP --
		cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y),
            t,
            xy(pos.x+0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- DOWN --
		cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y-0.12),
            t,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- LEFT --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y),
            t,
            xy(pos.x-0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
		-- RIGHT --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x+0.25, pos.y),
            t,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	
	-- UL --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y),
            t+depth,
            xy(pos.x-0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- UR --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x+0.25, pos.y),
            t+depth,
            xy(pos.x+0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- DL --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x-0.25, pos.y-0.12),
            t+depth,
            xy(pos.x-0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- DR --
	cmd.add(
        Event.arc(
            t,
            xy(pos.x+0.25, pos.y-0.12),
            t+depth,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )	
	
	-- BACK SIDE --
		-- UP --
		cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x-0.25, pos.y),
            t+depth,
            xy(pos.x+0.25, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- DOWN --
		cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x-0.25, pos.y-0.12),
            t+depth,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )

		-- LEFT --
	cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x-0.25, pos.y),
            t+depth,
            xy(pos.x-0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
		-- RIGHT --
	cmd.add(
        Event.arc(
            t+depth,
            xy(pos.x+0.25, pos.y),
            t+depth,
            xy(pos.x+0.25, pos.y-0.12),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )	
		cmd.commit();
		
		
		
	end
end
)



--- TRACE ART SECTION ---

addFolderWithIcon("hk.tools", "hk.tools.traceart", "e40a", "Trace arts (10)")


addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.rain", "Trace rain", "e3a5", 
function()
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local tS = startTimingRequest.result["timing"]
	
	local endTimingRequest = TrackInput.requestTiming(true, "Select end timing")
    coroutine.yield()
    local tE = endTimingRequest.result["timing"]
	local cmd = Command.create("Trace rain (hk.tools)")
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
		DialogField.create("1").description("Adjust the parameters"),
		
		DialogField.create("dens").setLabel("Density").defaultTo('1').setTooltip('').textField(FieldConstraint.create().integer()),
		DialogField.create("len").setLabel("Length").defaultTo('0.5').setTooltip('').textField(FieldConstraint.create().float()),
		
		DialogField.create("2").description("Adjust the boundary of the rain"),
		
        DialogField.create("xmin").setLabel("Left (X min)").defaultTo('-0.5').setTooltip('').textField(FieldConstraint.create().float()),
        DialogField.create("xmax").setLabel("Right (X max)").defaultTo('1.5').setTooltip('').textField(FieldConstraint.create().float()),
		DialogField.create("ymin").setLabel("Bottom (Y min)").defaultTo('0').setTooltip('').textField(FieldConstraint.create().float()),
        DialogField.create("ymax").setLabel("Top (Y max) ").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),	
	})
	  --requestInput code above
	coroutine.yield()
	
	local density 	= dialogRequest.result["dens"]+0
	local length 	= dialogRequest.result["len"]+0.0
	
	local X_min 	= dialogRequest.result["xmin"]+0.0
	local X_max		= dialogRequest.result["xmax"]+0.0
	local Y_min 	= dialogRequest.result["ymin"]+0.0
	local Y_max		= dialogRequest.result["ymax"]+0.0

	local arcLength = length * Context.beatLengthAt(tS) / Context.beatlineDensity
	local interval 	= Context.beatLengthAt(tS) / Context.beatlineDensity

	if (arcLength < 1) then
	arcLength = 1
	end	

	if (density <= 0) then
	
	DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("Density must not be or less than zero!"),
    })
	else
		

		local i = density
	
		while (i > 0) do
	
			local j = tS 
			while (j < tE) do
			local ranx = math.random(X_min*10000, X_max*10000)
			local rany = math.random(Y_min*10000, Y_max*10000)
		
			cmd.add(
				Event.arc(
					j,
					xy(ranx/10000,rany/10000),
					j+arcLength,
					xy(ranx/10000,rany/10000),
					true,
					0,
					's',
					Context.currentTimingGroup
					).save()
				)	
			j = j+interval
		end
	
	
	i = i-1
	end
	
	cmd.commit();
	
end
	
end
)


addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.trianglebase", "Triangle Base", "e86b", 
function()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]
	
	local basePositionRequest = TrackInput.requestPosition(t, "Select base position")
    coroutine.yield()
    local base_pos = basePositionRequest.result["xy"]
	
	local topPositionRequest = TrackInput.requestPosition(t, "Select peak position")
    coroutine.yield()
    local peak_pos = topPositionRequest.result["xy"]
	
	local cmd = Command.create("Triangle Base (hk.tools)")
	
	-- Base line---
	cmd.add(
        Event.arc(
            t,
            xy(base_pos.x+0.1, base_pos.y),
            t,
            xy(base_pos.x-0.1, base_pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	
	-- R side line---
	cmd.add(
        Event.arc(
            t,
            xy(base_pos.x+0.1, base_pos.y),
            t,
            peak_pos,
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	-- L side line---
	cmd.add(
        Event.arc(
            t,
            xy(base_pos.x-0.1, base_pos.y),
            t,
            peak_pos,
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	cmd.commit();
	
	
end
)



addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.diamondtrace", "Diamond", "ead5", 
function()

	local startTimingRequest = TrackInput.requestTiming(true, "Select timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]

    local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]

	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("w").setLabel("Width").defaultTo('0.3').setTooltip('').textField(FieldConstraint.create().float()),
        DialogField.create("h").setLabel("Heigth").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local size_X = dialogRequest.result["w"]
	local size_Y = dialogRequest.result["h"]
	

	
	local cmd = Command.create("Diamond trace (hk.tools)")
	
--	local size_X = 0.3			-->THIS MUST BE ABLE TO CUSTOMIZE
--	local size_Y = 1			-->THIS MUST BE ABLE TO CUSTOMIZE
	
	--UR arc--
	cmd.add(
        Event.arc(
            t,
            xy(pos.x, pos.y+size_Y/2),
            t,
            xy(pos.x+size_X/2, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	--DL arc--
	cmd.add(
        Event.arc(
            t,
            xy(pos.x, pos.y-size_Y/2),
            t,
            xy(pos.x-size_X/2, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	--UL arc--
	cmd.add(
        Event.arc(
            t,
            xy(pos.x, pos.y+size_Y/2),
            t,
            xy(pos.x-size_X/2, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	--DR arc--
	cmd.add(
        Event.arc(
            t,
            xy(pos.x, pos.y-size_Y/2),
            t,
            xy(pos.x+size_X/2, pos.y),
            true,
            0,
            's',
            Context.currentTimingGroup
        ).save()
    )
	cmd.commit();



end
)



addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.circle", "Polygons/Circles", "eb50", 
function()

	local startTimingRequest = TrackInput.requestTiming(true, "Select timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]

    local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]

	local cmd = Command.create("Polygon trace (hk.tools)")
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("p").setLabel("Polygon").defaultTo('8').setTooltip('').textField(FieldConstraint.create().integer()),
        DialogField.create("a").setLabel("Angle°").defaultTo('0').setTooltip('Rotate your polygon to the different angle').textField(FieldConstraint.create().float()),
		DialogField.create("h").setLabel("Width").defaultTo('0.25').setTooltip('Radius in x axis').textField(FieldConstraint.create().float()),
        DialogField.create("w").setLabel("Heigth").defaultTo('0.5').setTooltip('Radius in y axis').textField(FieldConstraint.create().float()),
		DialogField.create("x").setLabel("Pos X").defaultTo(tostring(pos.x)).setTooltip('Adjust your x position').textField(FieldConstraint.create().float()),
		DialogField.create("y").setLabel("Pos Y").defaultTo(tostring(pos.y)).setTooltip('Adjust your y position').textField(FieldConstraint.create().float()),
		
	})
	  --requestInput code above
	coroutine.yield()

	local polynum 		= dialogRequest.result["p"]+0
	local startAngle 	= dialogRequest.result["a"]+0.0
	local size_X 		= dialogRequest.result["h"]+0.0
	local size_Y 		= dialogRequest.result["w"]+0.0
	local new_X  		= dialogRequest.result["x"]+0.0
	local new_Y  		= dialogRequest.result["y"]+0.0
	
		

	pos.x = new_X
	pos.y = new_Y

	function arccreate(tS, posS, posE)
		
		cmd.add(
			Event.arc(
				tS,
				posS,
				tS,
				posE,
				true,
				0,
				's',
				Context.currentTimingGroup
				).save()
			)
		
	end
	
		
		i = 0
	while (i<polynum) do 
		nextAngle = startAngle+360/polynum
		startPosX = math.cos(math.rad(startAngle))
		startPosY = math.sin(math.rad(startAngle))
		
		endPosX = math.cos(math.rad(nextAngle))
		endPosY = math.sin(math.rad(nextAngle))
		startAngle = nextAngle
		i = i+1
		arccreate(t, xy(startPosX*size_X+pos.x,startPosY*size_Y+pos.y), xy(endPosX*size_X+pos.x,endPosY*size_Y+pos.y))
		
	end
	cmd.commit();

end
)




addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.circlehori", "Circle Trace (Horizontal)", "ef4a", 
function()

    
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local tStart = startTimingRequest.result["timing"]
	
	local positionRequest = TrackInput.requestPosition(tStart, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]

	local endTimingRequest = TrackInput.requestTiming(true, "Select end timing")
    coroutine.yield()
    local tEnd = endTimingRequest.result["timing"]
	

	local cmd = Command.create("Circle Trace (Horizontal) (hk.tools)")
	if (tEnd < tStart) then
		local a = tStart
		tStart = tEnd
		tEnd = a
	end
	if (tEnd == tStart) then
		DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").description("The length must not be the same!"),
    })
	else
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("p").setLabel("Polygon").defaultTo('16').setTooltip('').textField(FieldConstraint.create().integer()),
		DialogField.create("w").setLabel("Width").defaultTo('0.25').setTooltip('Radius in x axis').textField(FieldConstraint.create().float()),
	})
	  --requestInput code above
	coroutine.yield()

	local polynum 		= dialogRequest.result["p"]+0
	local size_X 		= dialogRequest.result["w"]+0
	function arccreate(tS, posS, posE, tE)
		
		cmd.add(
			Event.arc(
				tS,
				posS,
				tE,
				posE,
				true,
				0,
				's',
				Context.currentTimingGroup
				).save()
				)
		
	end
	
		
		i = 0
		startAngle = 450
	while (i<polynum/2) do 
		nextAngle = startAngle-360/polynum
		startPosX = math.cos(math.rad(startAngle))
		startPosY = math.sin(math.rad(startAngle))
		
		endPosX = math.cos(math.rad(nextAngle))
		endPosY = math.sin(math.rad(nextAngle))
		startAngle = nextAngle
		
		tE = math.floor(tStart+((tEnd-tStart)*(startPosY+1))/2)
		tS = math.floor(tStart+((tEnd-tStart)*(endPosY+1))/2)
		--dialogNotify (tS..'\n'..tE)
		
		--[[dialogNotify(	'startPosX\t'..startPosX..
						'\nstartPosY\t'..startPosY..
						'\nendPosX\t'..endPosX..
						'\nendPosY\t'..endPosY)
		]]
		arccreate(	tS, 
					xy(endPosX*size_X+pos.x,pos.y), 
					xy(startPosX*size_X+pos.x,pos.y),
					tE
				)
		i=i+1
		--addT = addT + (tEnd-tStart)/polynum/2
		end
	i=0
	startAngle = 450
	while (i<polynum/2) do 
		nextAngle = startAngle+360/polynum
		startPosX = math.cos(math.rad(startAngle))
		startPosY = math.sin(math.rad(startAngle))
		
		endPosX = math.cos(math.rad(nextAngle))
		endPosY = math.sin(math.rad(nextAngle))
		startAngle = nextAngle
		
		tE = math.floor(tStart+((tEnd-tStart)*(startPosY+1))/2)
		tS = math.floor(tStart+((tEnd-tStart)*(endPosY+1))/2)
		--dialogNotify (tS..'\n'..tE)
		
		--[[dialogNotify(	'startPosX\t'..startPosX..
						'\nstartPosY\t'..startPosY..
						'\nendPosX\t'..endPosX..
						'\nendPosY\t'..endPosY)
		]]
		arccreate(	tS, 
					xy(endPosX*size_X+pos.x,pos.y), 
					xy(startPosX*size_X+pos.x,pos.y),
					tE
				)
		i=i+1
		--addT = addT + (tEnd-tStart)/polynum/2
		end
	

	
	
	end
	cmd.commit();
end
)



--- JUST ART ---


function traceArt(art, t, pos, size) 

		-- ARC DRAWING FUNCTION --
	
--[[	function arccreate(tS, posS, posE, tE)
		
		local cmd = Command.create("Arctap box (hk.tools)")
		cmd.add(
			Event.arc(
				tS,
				posS,
				tE,
				posE,
				true,
				0,
				's',
				Context.currentTimingGroup
				).save()
				)
		cmd.commit();
		
	end
]]--

		-- SIZE --

		offsetx = 0
		offsety = 0

		-- ARRAY --
		
			-- HEART TRACES --
		if (art == 'heart') then
		x1 = {0.7,0.27,0.26,0.25,0.25,0.26,0.45,0.29,0.35,0.31,0.34,0.37,0.5,0.4,0.65,0.3,0.52,0.73,0.73,0.74,0.75,0.75,0.74,0.75,0.27,0.25,0.69,0.66,0.63,0.5,0.6,0.55,0.71,0.48}
		x2 = {0.65,0.3,0.27,0.26,0.25,0.25,0.48,0.27,0.4,0.29,0.31,0.34,0.37,0.45,0.6,0.35,0.5,0.74,0.7,0.73,0.74,0.75,0.75,0.75,0.26,0.25,0.71,0.69,0.66,0.63,0.55,0.52,0.73,0.5}
		y1 = {0.9,0.85,0.8,0.75,0.7,0.6,0.91,0.5,0.95,0.45,0.4,0.35,0.15,0.95,0.95,0.9,0.86,0.55,0.85,0.8,0.75,0.7,0.6,0.65,0.55,0.65,0.45,0.4,0.35,0.15,0.95,0.91,0.5,0.86}
		y2 = {0.95,0.9,0.85,0.8,0.75,0.65,0.86,0.55,0.95,0.5,0.45,0.4,0.35,0.91,0.95,0.95,0.8,0.6,0.9,0.85,0.8,0.75,0.65,0.7,0.6,0.7,0.5,0.45,0.4,0.35,0.91,0.86,0.55,0.8}
		offsety = -0.05
		end
		
		if (art == 'star1') then
		x1 = {0.50,0.52,0.56,0.62,0.50,0.52,0.56,0.62,0.50,0.48,0.44,0.38,0.50,0.48,0.44,0.38}
		x2 = {0.52,0.56,0.62,0.70,0.52,0.56,0.62,0.70,0.48,0.44,0.38,0.30,0.48,0.44,0.38,0.30}
		y1 = {0.00,0.19,0.35,0.46,1.00,0.81,0.65,0.54,0.00,0.19,0.35,0.46,1.00,0.81,0.65,0.54}
		y2 = {0.19,0.35,0.46,0.50,0.81,0.65,0.54,0.50,0.19,0.35,0.46,0.50,0.81,0.65,0.54,0.50}
		end
		
		if (art == 'star2') then
		x1 = {0.35,0.51,0.50,0.51,0.53,0.56,0.60,0.65,0.50,0.50,0.44,0.47,0.49,0.50,0.49,0.47,0.44,0.40,0.53,0.56}
		x2 = {0.30,0.53,0.51,0.50,0.51,0.53,0.56,0.70,0.50,0.50,0.40,0.44,0.47,0.49,0.50,0.49,0.47,0.44,0.56,0.60}
		y1 = {0.50,0.31,0.20,0.69,0.59,0.52,0.50,0.50,0.10,0.90,0.48,0.41,0.31,0.20,0.69,0.59,0.52,0.50,0.41,0.48}
		y2 = {0.50,0.41,0.31,0.80,0.69,0.59,0.52,0.50,0.00,1.00,0.50,0.48,0.41,0.31,0.80,0.69,0.59,0.52,0.48,0.50}
		end
		
		if (art == 'star3') then
		x1 = {0.58,0.58,0.30,0.47,0.58,0.75,0.58,0.30,0.40,0.47}
		x2 = {0.58,0.47,0.40,0.58,0.58,0.58,0.75,0.47,0.30,0.30}
		y1 = {0.62,0.98,0.79,0.31,0.02,0.50,0.38,0.21,0.50,0.69}
		y2 = {0.98,0.69,0.50,0.02,0.38,0.62,0.50,0.31,0.21,0.79}
		end
		
		if (art == 'custom') then
		x1 = {0.50,0.59,0.55,0.52,0.50,0.59,0.55,0.52,0.50,0.41,0.68,0.49,0.58,0.32,0.32,0.42,0.58,0.68,0.68,0.50,0.32,0.25,0.32,0.50,0.42,0.68,0.75,0.46,0.46,0.49,0.50,0.41}
		x2 = {0.49,0.65,0.59,0.55,0.52,0.65,0.59,0.55,0.52,0.35,0.68,0.46,0.68,0.42,0.32,0.32,0.42,0.58,0.75,0.68,0.50,0.32,0.25,0.32,0.58,0.50,0.68,0.41,0.41,0.46,0.49,0.35}
		y1 = {0.13,0.53,0.61,0.73,0.88,0.47,0.39,0.27,0.13,0.53,0.33,0.27,0.08,0.33,0.67,0.92,0.92,0.67,0.15,0.00,0.15,0.50,0.85,1.00,0.08,0.85,0.50,0.61,0.39,0.73,0.88,0.47}
		y2 = {0.27,0.50,0.53,0.61,0.73,0.50,0.47,0.39,0.27,0.50,0.67,0.39,0.33,0.08,0.33,0.67,0.92,0.92,0.50,0.15,0.00,0.15,0.50,0.85,0.08,1.00,0.85,0.53,0.47,0.61,0.73,0.50}

		end
		
		
		local cmd = Command.create("Trace arts (hk.tools)")
		--dialogNotify(Context.baseBpm)
		i = 1
		while (i<= #x1) do
--[[		arccreate(	t, 
					xy(
						(x1[i]-0.5+offsetx)*size+pos.x			,
						(y1[i]-0.5+offsety)*size+pos.y					
					), 
					
					xy(
						(x2[i]-0.5+offsetx)*size+pos.x			,
						(y2[i]-0.5+offsety)*size+pos.y					
					),
					t
				)
				
]]--	
		cmd.add(
			Event.arc(
							t,
							xy(
								(x1[i]-0.5+offsetx)*size+pos.x			,
								(y1[i]-0.5+offsety)*size+pos.y					
							),
							t,
							xy(
								(x2[i]-0.5+offsetx)*size+pos.x			,
								(y2[i]-0.5+offsety)*size+pos.y					
							),
							true,
							0,
							's',
							Context.currentTimingGroup
					).save()
				)

				i = i+1

		end
		cmd.commit();
		

end



addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.heart", "Heart", "e87d", 
function()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]
	
	local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("s").setLabel("Size").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local size = dialogRequest.result["s"]+0.0
	
	traceArt('heart', t, pos, size) 
	
end
)

addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.star1", "Star 1", "e65f", 
function()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]
	
	local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("s").setLabel("Size").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local size = dialogRequest.result["s"]+0.0
	
	traceArt('star1', t, pos, size) 
	
end
)

addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.star2", "Star 2", "e65f", 
function()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]
	
	local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("s").setLabel("Size").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local size = dialogRequest.result["s"]+0.0
	
	traceArt('star2', t, pos, size) 
	
end
)

addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.star3", "Star 3", "e838", 
function()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]
	
	local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("s").setLabel("Size").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local size = dialogRequest.result["s"]+0.0
	
	traceArt('star3', t, pos, size) 
	
end
)


addMacroWithIcon("hk.tools.traceart", "hk.tools.traceart.custom", "Custom", "e0ed", 
function()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local t = startTimingRequest.result["timing"]
	
	local positionRequest = TrackInput.requestPosition(t, "Select position")
    coroutine.yield()
    local pos = positionRequest.result["xy"]
	
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("s").setLabel("Size").defaultTo('1').setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local size = dialogRequest.result["s"]+0.0
	
	traceArt('custom', t, pos, size) 
	
end
)


addMacroWithIcon("hk.tools", "hk.tools.smoothtiming", "Smooth timing", "e91a",

    function ()
	
	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local tStart = startTimingRequest.result["timing"]
	
	local endTimingRequest = TrackInput.requestTiming(true, "Select end timing")
    coroutine.yield()
    local tEnd = endTimingRequest.result["timing"]
	local bpm = Context.baseBpm
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("int").setLabel("Division").defaultTo('8').setTooltip('').textField(FieldConstraint.create().integer()),
		DialogField.create("bpmstart").setLabel("Start BPM").defaultTo(tostring(bpm)).setTooltip('').textField(FieldConstraint.create().float()),
		DialogField.create("bpmend").setLabel("End BPM").defaultTo(tostring(bpm)).setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	
	local interval 	= dialogRequest.result["int"]+0
	local bpmStart 	= dialogRequest.result["bpmstart"]+0.0
	local bpmEnd 	= dialogRequest.result["bpmend"]+0.0
	
	interval_length = (tEnd-tStart)/interval
	interval_bpm = (bpmEnd-bpmStart)/interval
	
	local cmd = Command.create("Smooth timing (hk.tools)")
	
	
	local i = tStart
	local j = bpmStart
	local a = 9999
	while (i <= tEnd) do
	
			if ((i+interval_length) > tEnd) then
			a = 4
			i = tEnd
			end
			cmd.add(Event.timing(
				i, j, a, Context.currentTimingGroup
			).save())
			

	j = j+interval_bpm
	i = i+interval_length
	end

	cmd.commit();
	
end
)



addFolderWithIcon("hk.tools", "hk.tools.glitch", "ea0b", "Glitch timing (2)")


addMacroWithIcon("hk.tools.glitch", "hk.tools.glitch.steady", "Steady", "e5da", 
function()

	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local tStart = startTimingRequest.result["timing"]
	
	local endTimingRequest = TrackInput.requestTiming(true, "Select end timing")
    coroutine.yield()
    local tEnd = endTimingRequest.result["timing"]
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("fr").setLabel("Frequency").defaultTo('16').setTooltip('').textField(FieldConstraint.create().integer()),
		DialogField.create("bpm").setLabel("BPM").defaultTo(tostring(Context.baseBpm*2)).setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	
	local dt 		= dialogRequest.result["fr"]+0
	local bpm 		= dialogRequest.result["bpm"]+0.0
	local cmd 		= Command.create("Steady glitch timing (hk.tools)")
	local interval 	= math.floor((tEnd-tStart)/dt/2)
	local length 	= tEnd-tStart
	local i = 0
	local k = -1
	--dialogNotify('Start = '..tostring(tStart)..'\nEnd = '..tostring(tEnd)..'\ndt = '..tostring(length)..'\nInterval = '..tostring(interval))
	local xbpm = bpm
	while (i < length)
	do
		if (k==1) then
		xbpm = bpm
		else
		xbpm = bpm*(-1)
		end
		cmd.add(
                Event.timing(
                    tStart+i,
                    xbpm,
                    999.0,
                    Context.currentTimingGroup
                ).save()
            )
		k=k*(-1)	
		i=i+interval
	end
	
		cmd.add(
                Event.timing(
                    tEnd,
                    Context.baseBpm,
                    4.0,
                    Context.currentTimingGroup
                ).save()
            )
	cmd.commit();



end
)

addMacroWithIcon("hk.tools.glitch", "hk.tools.glitch.fw", "Forward", "e5da", 
function()

	local startTimingRequest = TrackInput.requestTiming(true, "Select start timing")
    coroutine.yield()
    local tStart = startTimingRequest.result["timing"]
	
	local endTimingRequest = TrackInput.requestTiming(true, "Select end timing")
    coroutine.yield()
    local tEnd = endTimingRequest.result["timing"]
	local dialogRequest = DialogInput.withTitle("Parameters").requestInput({
        DialogField.create("fr").setLabel("Frequency").defaultTo('16').setTooltip('').textField(FieldConstraint.create().integer()),
		DialogField.create("bpmfw").setLabel("BPM Forward").defaultTo(tostring(Context.baseBpm*4)).setTooltip('').textField(FieldConstraint.create().float()),
		DialogField.create("bpmbw").setLabel("BPM Backward").defaultTo(tostring(Context.baseBpm*(-2))).setTooltip('').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	
	local dt 		= dialogRequest.result["fr"]+0
	local bpm1 		= dialogRequest.result["bpmfw"]+0.0
	local bpm2 		= dialogRequest.result["bpmbw"]+0.0
	local cmd 		= Command.create("Steady glitch timing (hk.tools)")
	local interval = math.floor((tEnd-tStart)/dt/2)
	local length = tEnd-tStart
	local i = 0
	local k = -1
	--dialogNotify('Start = '..tostring(tStart)..'\nEnd = '..tostring(tEnd)..'\ndt = '..tostring(length)..'\nInterval = '..tostring(interval))
	local xbpm = bpm
	while (i < length)
	do
		if (k==1) then
		xbpm = bpm1
		else
		xbpm = bpm2
		end
		cmd.add(
                Event.timing(
                    tStart+i,
                    xbpm,
                    999.0,
                    Context.currentTimingGroup
                ).save()
            )
		k=k*(-1)	
		i=i+interval
	end
	cmd.add(
                Event.timing(
                    tEnd,
                    Context.baseBpm,
                    4.0,
                    Context.currentTimingGroup
                ).save()
            )
	cmd.commit();

end
)




--[[

--- DIALOG THINGS  ---
addMacroWithIcon("hk.tools", "hk.tools.test", "TEST", "f07e",

	function()

	
	local dialogRequest = DialogInput.withTitle("Caution!").requestInput({
        DialogField.create("1").setLabel("Hee Hom").defaultTo('0.9').setTooltip('HEE').textField(FieldConstraint.create().float()),
        DialogField.create("2").setLabel("Hee Yai").defaultTo('6.0').setTooltip('HUM').textField(FieldConstraint.create().float()),
    })
	  --requestInput code above
	coroutine.yield()
	local setX = dialogRequest.result["1"]
	local setY = dialogRequest.result["2"]
	
	DialogInput.withTitle("Error!").requestInput({
        DialogField.create("1").description("Sum = "..tostring(setX+setY)),
	})



end
)
-]]
