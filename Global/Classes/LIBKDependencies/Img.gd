### ----------------------------------------------------
### Sublib for image/texture related actions
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Interpolates BG texture with addColor
# Puts Outline texture on top of interpolated BG texture
# Returns null on failure
static func blend_textures(textureBG:Texture, textureOutline:Texture, addColor:Color, weight:float) -> Texture:
    var texture:ImageTexture = ImageTexture.new()
    if(not textureBG.get_size() == textureOutline.get_size()):
        push_error("Texture outline and bg must be same size: "+str(textureBG.get_size())+" "+str(textureOutline.get_size()))
        return null
    if(weight<0 or weight>1):
        push_error("Weight must be in range from 0 - 1: " + str(weight))
        return null
    
    var BGImage:Image = textureBG.get_data()
    var OutlineImage:Image = textureOutline.get_data()
    var blendImage:Image = Image.new()
    
    blendImage.create(textureBG.get_width(), textureBG.get_height(), false,Image.FORMAT_RGBA8)
    
    blendImage.lock()
    OutlineImage.lock()
    BGImage.lock()
    
    for x in range(BGImage.get_width()):
        for y in range(BGImage.get_height()):
            # Interpolate bg with addColor
            var BGPixel:Color = BGImage.get_pixel(x,y)
            if BGPixel.a != 0: BGPixel = BGPixel.linear_interpolate(addColor, weight) 
            
            # Put outline on
            var OutlinePixel:Color = OutlineImage.get_pixel(x,y)
            var blendPixel:Color = BGPixel
            if OutlinePixel.a != 0: blendPixel = BGPixel.linear_interpolate(OutlinePixel,1)
            
            blendImage.set_pixel(x, y, blendPixel)
    texture.create_from_image(blendImage, 0)
    return texture