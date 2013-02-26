local chart = {}

local color = {}
color[1] = "red"
color[2] = "green"
color[3] = "yellow"
color[4] = "orange"

backgroundColor = "#321E14"

local paddingLeft = 45
local paddingBottom = 40
local paddingTop = 30
local paddingRight = 45

local yAxisHeight = 0

function addAttribute(str, name, value)
	if not value or not name then return str end
	return str .. name .. '="' .. value .. '" '
end

function lineToSVG(x1,y1,x2,y2,color,width,animationTimeOffset,animationSpeed)
	local s
	
	if animationTimeOffset and animationSpeed then
		s = '<line '
		s = addAttribute(s, "x1", x1)
		s = addAttribute(s, "x2", x2)
		s = addAttribute(s, "y1", yAxisHeight)
		s = addAttribute(s, "y2", yAxisHeight)
		s = addAttribute(s, "stroke", color)
		s = addAttribute(s, "stroke-width", width)
		s = s .. '>\n'
		s = s .. '\t<animate attributeType="XML" attributeName="y2" from="' .. yAxisHeight .. '" to="' .. y2 .. '" dur="' .. animationSpeed .. 's" begin="' .. animationTimeOffset .. 's" fill="freeze" />\n'
		s = s .. '\t<animate attributeType="XML" attributeName="y1" from="' .. yAxisHeight .. '" to="' .. y1 .. '" dur="' .. animationSpeed .. 's" begin="' .. animationTimeOffset .. 's" fill="freeze" />\n'
		s = s .. '</line>\n'
	else
		s = '<line '
		s = addAttribute(s, "x1", x1)
		s = addAttribute(s, "x2", x2)
		s = addAttribute(s, "y1", y1)
		s = addAttribute(s, "y2", y2)
		s = addAttribute(s, "stroke", color)
		s = addAttribute(s, "stroke-width", width)
		s = s .. '/>\n'
	end
	
	return s
end

function textToSVG(x, y, size, text, align, rotate, color, boxLabel)
	local s = ""
	
	if boxLabel then
		s = s .. '\t<rect id="' .. boxLabel .. '-box" x="' .. x-5 .. '" y = "' .. y-5 .. '" border-radius="10" rx="5" ry="5" width="100" height="12" fill="#523E34" stroke-width="1" stroke="black"  style="opacity:0.5"/>\n'
	end
	
	s = s .. "\t<text "
	s = addAttribute(s, "x", x)
	s = addAttribute(s, "y", y)
	s = addAttribute(s, "font-size", size)
	if boxLabel then
		s = addAttribute(s, "id", boxLabel)
	end
	if align and align == "right" then
		s = addAttribute(s, "text-anchor", "end")
	end
	if rotate then
		s = addAttribute(s, "transform", "rotate(" .. rotate .. "," .. x .. "," .. y .. ")")
	end
	if not color then color = "white" end
	s = addAttribute(s, "fill", color)
	if not boxLabel then
		s = s .. "> " .. text .. " </text>\n"
	else
		s = s .. '>\n\t\t<tspan id="tspan1">' .. text .. " </tspan>\n\t</text>\n"
	end
	
	return s
end

function sortPoints(a,b)
	if a and b then
		if a.x ~= b.x then
			return a.x < b.x
		else
			return a.y < b.y
		end
	end
end

function writeHeader(width, height)
	s ='<?xml version="1.0" standalone="no"?>\n'
	s = s .. '<svg width="' .. width .. '" height="' .. height .. '" viewBox="0 0 ' .. width .. ' ' .. height .. '" xmlns="http://www.w3.org/2000/svg" version="1.1"\n'
	s = s .. 'xmlns:xlink="http://www.w3.org/1999/xlink">\n'
	s = s .. '\n\n<!-- Generate background: -->\n\t<rect x="1" y="1" border-radius="10" rx="20" ry="20" width="' .. width - 2 .. '" height="' .. height -2 .. '" fill="' .. backgroundColor .. '" stroke-width="1" stroke="black" />\n'
	return s
end

function writeCoordinateSystem(width, height, maxX, maxY)
	local s = ""
	
	s = s .. "\n<!-- Coordinate System: -->\n"
	
	local h = (height-paddingBottom-paddingTop)
	local stepSize = math.floor(math.max(h/10, 30))
	for y = paddingTop, height-paddingBottom, stepSize do
		if (h-(y-paddingTop)) > 0 then
			s = s .. "\t" .. lineToSVG(paddingLeft, y, width-paddingRight, y, "grey", 1)
			s = s .. "\t" .. textToSVG(paddingLeft-4, y+2, 10, math.floor((h-(y-paddingTop))/h*maxY), "right", nil, "white")
		end
	end
	
	local w = width-paddingLeft-paddingRight
	local stepSize = math.max(w/10, 40)
	for x = paddingLeft, width-paddingRight, stepSize do
		s = s .. "\t" .. textToSVG(x, height-paddingBottom + 15, 10, math.floor((x-paddingLeft)/w*maxX), "right", nil, "white")
	end
	
	s = s .. "\n"
	s = s .. "<!-- Axis: -->\n"
	
	s = s .. "\t" .. lineToSVG(paddingLeft, height-paddingBottom, width-paddingRight, height-paddingBottom, "white", 3)
	s = s .. "\t" .. lineToSVG(paddingLeft, paddingTop, paddingLeft, height-paddingBottom, "white", 3)
	
	yAxisHeight = height-paddingBottom
	
	return s
end

-- a function that will add a script to the file which can draw the borders around the texts elements.
function writeBorderScript(points)
	local s = [[
	<script type="text/ecmascript">
		function add_bounding_box (text_id, padding) {
			var text_elem = document.getElementById(text_id);
			if (text_elem) {
				var t = text_elem.getClientRects();
				var r = document.getElementById(text_id + '-box');
				if (t) {
					if (r) {
				    r.setAttribute('x', t[0].left - padding);
					r.setAttribute('y', t[0].top - padding);
					r.setAttribute('width', t[0].width + padding * 2);
					r.setAttribute('height', t[0].height + padding * 2);
				    }
				}
			}
		}
		]]
		
	for k, p in pairs(points) do
		s = s .. "\n\t\tadd_bounding_box('" .. p.name .."', 2);"
	end
	s = s .. "\n\t</script>\n"
	return s
end

function chart.generate(fileName, width, height, points, xLabel, yLabel, style, animationTime)
	-- don't allow an empty list. At least one set of data is needed:
	if #points < 1 then return end
	
	-- setup defaults:
	animationTime = animationTime or 5
	style = style or "line"
	
	-- sort list by x, then by y:
	for i=1,#points do
		table.sort(points[i], sortPoints)
	end
	
	local chartContent = writeHeader(width, height)
	
	if style == "line" then
	
		maxX = 1
		maxY = 1
		for i=1,#points do
			if points[i][#points[i]] then
				maxX = math.max(points[i][#points[i]].x, maxX) -- enough, because list was sorted by x
			end
			for j=1,#points[i] do
				maxY = math.max(points[i][j].y, maxY)
			end
		end
		-- scale all data to fit onto the chart:
		for i=1,#points do
			for j=1,#points[i] do
				points[i][j].x = paddingLeft + (width-paddingLeft-paddingRight)*points[i][j].x/maxX
				points[i][j].y = (height-paddingBottom-paddingTop)*(maxY-points[i][j].y)/maxY + paddingTop
			end
		end
		
		chartContent = chartContent .. writeCoordinateSystem(width, height, maxX, maxY)
		chartContent = chartContent .. textToSVG(15, paddingTop, 12, yLabel, "right", -90)
		chartContent = chartContent .. textToSVG(width-paddingRight, height-10, 12, xLabel, "right")
		
		
		animTime = 0
		
		for i=1,#points do
			chartContent = chartContent .. "\n<!-- Data Set " .. i .. " -->\n"
			animSpeed = 1/#points[i]
			for j=1,#points[i]-1 do
				animTime = animTime + animSpeed
				chartContent = chartContent .. "\t" .. lineToSVG(points[i][j].x, points[i][j].y, points[i][j+1].x, points[i][j+1].y, color[i], 2, animTime, animSpeed)
			end
			animTime = animTime + .5
		end
		
		local x = paddingLeft + 10
		local y = paddingTop
		for i=1,#points do	-- label all the lines:
			if points[i][#points[i]] and points[i].name and #points[i] > 1 then
				local attachPoint = math.random(#points[i])
				if #points[i] > 1 and attachPoint < 2 then
					attachPoint = 2
				end
				local lastX = x + math.random(10)
				chartContent = chartContent .. textToSVG(lastX, y, 12, points[i].name, "left", nil, color[i], points[i].name)
				y = y + 15
			end
		end
		
		chartContent = chartContent .. writeBorderScript(points)
		chartContent = chartContent .. "</svg>\n"
		
	end
	
	file = io.open(fileName, "w")
	if file then
		file:write(chartContent)
		file:close()
	end
end

return chart