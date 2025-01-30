how to use:
copy the following files to anywhere in your godot project:
block_ui.gd
block_ui.tscn
grid_ui.gd
grid_ui.tscn

to add a grid to your game, right click the node you want to add the grid to and select "Instantiate child scene..."
then select "GridUI" in the options
it extends NinePatchRect, so you can configure it with those properties as well
you can set the selection sprite via the attribute "Selection Ninepatch" in the Inspector

to add items to the grid, right click the grid node you want to add the item to and select "Instantiate child scene..."
then select "BlockUI" in the options
configure this one normally as a TextureButton
