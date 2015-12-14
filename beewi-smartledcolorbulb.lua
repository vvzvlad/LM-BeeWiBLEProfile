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
      name = 'Color temperature',
      datatype = dt.scale
    },
    {
      id = 'color',
      name = 'RGB color',
      datatype = dt.rgb
    },
    {
      id = 'brightness',
      name = 'Brightness',
      datatype = dt.scale
    },
  },
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
        values.white = (bit.band(value_0x24:byte(2), 15)-1)*10
        values.brightness = ((bit.rshift(bit.band(value_0x24:byte(2), 240), 4)-1)*10)
        values.color = bit.lshift(bit.band(value_0x24:byte(3),0xFF),16) + bit.lshift(bit.band(value_0x24:byte(4),0xFF),8) + bit.band(value_0x24:byte(5),0xFF)
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
        ble.sockwritecmd(sock, 0x21, 0x55, 0x13, red, green, blue, 0x0D, 0x0A)
      end
    end

    if (object.id == 'white') then
      if res then
        ble.sockwritecmd(sock, 0x21, 0x55, 0x14, 0xFF, 0xFF, 0xFF, 0x0D, 0x0A)
        ble.sockwritecmd(sock, 0x21, 0x55, 0x11, (value/10)+1, 0x0D, 0x0A)
      end
    end

    if (object.id == 'brightness') then
      if res then
        ble.sockwritecmd(sock, 0x21, 0x55, 0x12, (value/10)+1, 0x0D, 0x0A)
      end
    end

    ble.close(sock)
  end
}
