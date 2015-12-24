return { 
  manufacturer = 'BeeWi',
  description = 'Smart LED Color Bulb',
  default_name = 'BeeWi Bulb',
  version = 1,  
  objects = { 
    {
      id = 'power',
      name = 'Power',
      datatype = dt.bool,
    write_only = true
    },
    {
      id = 'power_status',
      name = 'Power status',
      datatype = dt.bool,
    read_only = true
    },
    {
      id = 'white',
      name = 'Color temperature',
      datatype = dt.scale,
    write_only = true
    },
    {
      id = 'white_status',
      name = 'Color temperature status',
      datatype = dt.scale,
    read_only = true
    },
    {
      id = 'color',
      name = 'RGB color',
      datatype = dt.rgb,
    write_only = true
    },
    {
      id = 'color_status',
      name = 'RGB color status',
      datatype = dt.rgb,
    read_only = true
    },
    {
      id = 'brightness',
      name = 'Brightness',
      datatype = dt.scale,
    write_only = true
    },
    {
      id = 'brightness_status',
      name = 'Brightness Status',
      datatype = dt.scale,
    read_only = true
    }
  },
  
  read = function(device)
    local values = {}
    local res, sock, err  = device.profile._connect(device)

    local status
    if res and sock then
      local value_0x24 = ble.sockreadhnd(sock, 0x24) or ''
      if (#value_0x24 == 5) then   
      status = true
      if (value_0x24:byte(1) == 0) then
        values.power_status = false
      elseif (value_0x24:byte(1) == 1) then
        values.power_status = true
      end
      values.white_status = (bit.band(value_0x24:byte(2), 15)-1) * 10 
      values.brightness_status = ((bit.rshift(bit.band(value_0x24:byte(2), 240), 4)-1)) * 10 
      values.color_status = bit.lshift(bit.band(value_0x24:byte(3),0xFF),16) + bit.lshift(bit.band(value_0x24:byte(4),0xFF),8) + bit.band(value_0x24:byte(5),0xFF)
      end
    end

    if not status then 
      device.profile._disconnect(device) 
    end 

    return status, values
  end,
  
  write = function(device, object, value)
    local res, sock, err  = device.profile._connect(device)
    
    local res2 = true 
    if res and sock then
      if (object.id == 'power') then
        if (value == true) then
          res2, err = ble.sockwritecmd(sock, 0x21, 0x55, 0x10, 0x01, 0x0D, 0x0A)
        end
        if (value == false) then
          res2, err = ble.sockwritecmd(sock, 0x21, 0x55, 0x10, 0x00, 0x0D, 0x0A)
        end

      elseif (object.id == 'color') then
        red = bit.band(bit.rshift(value, 16), 0xFF)
        green = bit.band(bit.rshift(value, 8), 0xFF)
        blue = bit.band(value, 0xFF)
        res2, err = ble.sockwritecmd(sock, 0x21, 0x55, 0x13, red, green, blue, 0x0D, 0x0A)

      elseif (object.id == 'white') then
        value =  math.floor(value / 10 +0.5)
        ble.sockwritecmd(sock, 0x21, 0x55, 0x14, 0xFF, 0xFF, 0xFF, 0x0D, 0x0A)
        res2, err = ble.sockwritecmd(sock, 0x21, 0x55, 0x11, (value)+1, 0x0D, 0x0A)

      elseif (object.id == 'brightness') then
        value =  math.floor(value / 10 +0.5)
        res2, err = ble.sockwritecmd(sock, 0x21, 0x55, 0x12, (value)+1, 0x0D, 0x0A)
      end 
    end 

    if res2<=0 then 
      device.profile._disconnect(device) 
    end 
  end,

  _connect = function(device) 
    local res, err = true, nil 
    
    local sock = device.sock 
    
    if not sock or not ble.check(sock) then 
      if sock then 
        ble.close(sock) 
      end 
      
      sock = ble.sock() 
      ble.settimeout(sock, 30) 
      local i = 1 
      res, err = 1, ble.connect(sock, device.mac) 
      while not res and i<10 do  --не всегда коннектится с первой попытки 
        os.sleep(0.5) 
        res, err = ble.connect(sock, device.mac)
        i = i + 1 
      end 
      
      if not res then 
        ble.close(sock) 
        sock = nil 
      end 
        
      device.sock = sock 
    end 
    
    return res, sock, err 
  end,

  _disconnect = function(device) 
    local sock = device.sock 
    if sock then 
      ble.close(sock)   
    end 
    device.sock = nil 
  end 
}
