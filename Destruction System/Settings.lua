local Settings = {}
Settings.SetOwnerShip = true -- this will set ownership to the closest player if player isnt provided
Settings.OverlapParams = OverlapParams.new() --RaycastParams configure this however you want
Settings.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
Settings.OverlapParams.FilterDescendantsInstances = {workspace.Ignored}
Settings.FadeOutMinSize = 1 -- if the part is under this size it will fade out \
Settings.FadeOutTime = 2 -- how long it will take a part to fade out slowly
Settings.AnchorThePart = true -- after the part lands on the ground it will be anchored to reduce on Physics and in doing so the preformacne will improve
Settings.GoalSize = 2.2 -- Goal size for the part
Settings.SetPartToMassless = true -- Will set the part to massless after its unanchored
Settings.ApplyForce = true -- this will apply force to the part to kick the part away (you must provide "DirectionPart")
Settings.Force = 5-- The Force it will apply (Default if its not provided)
--Settings.DoGreedyMeshing = true  -- this will probably not be added since greedy meshing isnt required here
Settings.Regenerate = true -- Regenerate (as of now not in use)
Settings.DefaultRegenerationTime = 30 -- Default RegenerationTime if regeneration time isnt provided in the data table
Settings.Debug = false


-- no breakingsounds YET

Settings.BreakingSound = {
	
}


return Settings
