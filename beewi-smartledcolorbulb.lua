return {
  manufacturer = 'BeeWi',
  description = 'Smart LED Color Bulb',
  default_name = 'BeeWi Bulb',
  objects = {
    {
      id = 'raw',
      name = 'RAW data',
      datatype = dt.string
    },
    {
      id = 'power',
      name = 'Power',
      datatype = dt.bool
    },
    {
      id = 'color',
      name = 'Color',
      datatype = dt.rgb
    },
  },
  init = function(device)
    local objects = device.objects
  end,
  read = function(device)
    local sock
    values = {}

    sock = ble.sock()

    ble.settimeout(sock, 30)
    res = ble.connect(sock, device.mac)
    if res then
      value_0x24 = ble.sockreadhnd(sock, 0x24) or ''
      if (#value_0x24 == 5) then   
        status = true
        if (value_0x24:byte(1) == 0) then
          values.power = false
        elseif (value_0x24:byte(1) == 1) then
          values.power = true
        end

        values.raw = value_0x24
        
      end
    end

    ble.close(sock)
   
    return status, values
  end,
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
        if (red == 255 and green == 255 and blue == 255) then 
          ble.sockwritecmd(sock, 0x21, 0x55, 0x14, 0xFF, 0xFF, 0xFF, 0x0D, 0x0A)
        else
          ble.sockwritecmd(sock, 0x21, 0x55, 0x13, red, green, blue, 0x0D, 0x0A)
        end
      end
    end

    ble.close(sock)
  end
}
