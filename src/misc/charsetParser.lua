
charsize = 64

charsetParser = {}

function charsetParser.parseCharset()
    
    charset = love.graphics.newImage("ressource/charset_test.png")
    
    local refW = charset:getWidth()
    local refH = charset:getHeight()
    
    anim_quad = {}
    for i = 0,7 do
        anim_quad["walk_u"..(i + 1)] = love.graphics.newQuad(i * charsize, 8 * charsize, charsize, charsize, refW, refH)
        anim_quad["walk_l"..(i + 1)] = love.graphics.newQuad(i * charsize, 9 * charsize, charsize, charsize, refW, refH)
        anim_quad["walk_d"..(i + 1)] = love.graphics.newQuad(i * charsize, 10 * charsize, charsize, charsize, refW, refH)
        anim_quad["walk_r"..(i + 1)] = love.graphics.newQuad(i * charsize, 11 * charsize, charsize, charsize, refW, refH)
    end
    
    for i = 0,5 do
        anim_quad["work_u"..(i + 1)] = love.graphics.newQuad(i * charsize, 12 * charsize, charsize, charsize, refW, refH)
        anim_quad["work_l"..(i + 1)] = love.graphics.newQuad(i * charsize, 13 * charsize, charsize, charsize, refW, refH)
        anim_quad["work_d"..(i + 1)] = love.graphics.newQuad(i * charsize, 14 * charsize, charsize, charsize, refW, refH)
        anim_quad["work_r"..(i + 1)] = love.graphics.newQuad(i * charsize, 15 * charsize, charsize, charsize, refW, refH)
    end
    
end
    