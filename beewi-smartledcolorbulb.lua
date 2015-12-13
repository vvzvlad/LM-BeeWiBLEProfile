return {
  manufacturer = 'BeeWi',
  description = 'Smart LED Color Bulb',
  default_name = 'BeeWi Bulb',
  objects = {
    {
      id = 'power',
      name = 'Power',
      datatype = dt.bool
    },
    {
      id = 'white',
      name = 'White',
      datatype = dt.scale
    },
    {
      id = 'color',
      name = 'Color',
      datatype = dt.rgb
    },
    {
      id = 'brightness',
      name = 'Brightness',
      datatype = dt.scale
    },
  },
  write = function(device, object, value)
    local sock
    sock = ble.sock()
    ble.settimeout(sock, 30)
    res = ble.connect(sock, device.mac)

    if (object.id == 'power') then
      if res then
        if (value == true) then
          ble.sockwritecmd(sock, 0x21, 0x55, 0x10, 0x01, 0x0D, 0x0A)
        end
        if (value == false) then
          ble.sockwritecmd(sock, 0x21, 0x55, 0x10, 0x00, 0x0D, 0x0A)
        end
      end
    end

    if (object.id == 'color') then
      if res then
        red = bit.band(bit.rshift(value, 16), 0xFF)
        green = bit.band(bit.rshift(value, 8), 0xFF)
        blue = bit.band(value, 0xFF)
        ble.sockwritecmd(sock, 0x21, 0x55, 0x13, red, green, blue, 0x0D, 0x0A)
      end
    end

    if (object.id == 'white') then
      if res then
        ble.sockwritecmd(sock, 0x21, 0x55, 0x14, 0xFF, 0xFF, 0xFF, 0x0D, 0x0A)
        if (value >= 0 and value < 10) then bite = 0x02
        elseif (value >= 10 and value < 20) then bite = 0x03 
        elseif (value >= 20 and value < 30) then bite = 0x04
        elseif (value >= 30 and value < 40) then bite = 0x05
        elseif (value >= 40 and value < 50) then bite = 0x06
        elseif (value >= 50 and value < 60) then bite = 0x07
        elseif (value >= 60 and value < 70) then bite = 0x08
        elseif (value >= 70 and value < 80) then bite = 0x09
        elseif (value >= 80 and value < 90) then bite = 0x0A 
        elseif (value >= 90 and value <= 100) then bite = 0x0B
        end
        log(bite)
        ble.sockwritecmd(sock, 0x21, 0x55, 0x11, bite, 0x0D, 0x0A)
      end
    end

    if (object.id == 'brightness') then
      if res then
        if (value >= 0 and value < 10) then bite = 0x02
        elseif (value >= 10 and value < 20) then bite = 0x03 
        elseif (value >= 20 and value < 30) then bite = 0x04
        elseif (value >= 30 and value < 40) then bite = 0x05
        elseif (value >= 40 and value < 50) then bite = 0x06
        elseif (value >= 50 and value < 60) then bite = 0x07
        elseif (value >= 60 and value < 70) then bite = 0x08
        elseif (value >= 70 and value < 80) then bite = 0x09
        elseif (value >= 80 and value < 90) then bite = 0x0A 
        elseif (value >= 90 and value <= 100) then bite = 0x0B
        end
        log(bite)
        ble.sockwritecmd(sock, 0x21, 0x55, 0x12, bite, 0x0D, 0x0A)
      end
    end

    ble.close(sock)
  end
}
