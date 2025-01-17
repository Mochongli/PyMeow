import
  os, colors,
  nimpy, winim,
  overlay, vector

const cheatsheet = staticRead("../cheatsheet.txt")

pyExportModule("pymeow")

proc key_pressed(vKey: int32): bool {.exportpy.} =
  GetAsyncKeyState(vKey).bool

proc set_foreground(winTitle: string): bool {.discardable, exportpy.} = 
  SetForeGroundWindow(FindWindowA(nil, winTitle))

proc mouse_move(a: Overlay, x, y: float32) {.exportpy.} =
  var input: INPUT
  input.mi = MOUSE_INPUT(
    dwFlags: MOUSEEVENTF_MOVE, 
    dx: (x - a.midX).int32,
    dy: -(y - a.midY).int32,
  )
  SendInput(1, input.addr, sizeof(input).int32)

proc mouse_click {.exportpy.} =
  var 
    down: INPUT
    release: INPUT

  down.mi = MOUSE_INPUT(dwFlags: MOUSEEVENTF_LEFTDOWN)
  release.mi = MOUSE_INPUT(dwFlags: MOUSEEVENTF_LEFTUP)

  SendInput(1, down.addr, cast[int32](sizeof(down)))
  sleep(3)
  SendInput(1, release.addr, cast[int32](sizeof(release)))

proc rgb(color: string): array[0..2, float32] {.exportpy.} =
  try:
    let c = parseColor(color).extractRGB()
    [c.r.float32, c.g.float32, c.b.float32]
  except:
    [0.float32, 0, 0]

proc wts_ogl(a: Overlay, matrix: array[0..15, float32], pos: Vec3): Vec2 {.exportpy.} =
  var 
    clip: Vec3
    ndc: Vec2

  # z = w
  clip.z = pos.x * matrix[3] + pos.y * matrix[7] + pos.z * matrix[11] + matrix[15]
  if clip.z < 0.2:
    raise newException(Exception, "WTS")

  clip.x = pos.x * matrix[0] + pos.y * matrix[4] + pos.z * matrix[8] + matrix[12]
  clip.y = pos.x * matrix[1] + pos.y * matrix[5] + pos.z * matrix[9] + matrix[13]

  ndc.x = clip.x / clip.z
  ndc.y = clip.y / clip.z

  result.x = (a.width / 2 * ndc.x) + (ndc.x + a.width / 2)
  result.y = (a.height / 2 * ndc.y) + (ndc.y + a.height / 2)

proc wts_dx(a: Overlay, matrix: array[0..15, float32], pos: Vec3): Vec2 {.exportpy.} =
  var 
    clip: Vec3
    ndc: Vec2

  # z = w
  clip.z = pos.x * matrix[12] + pos.y * matrix[13] + pos.z * matrix[14] + matrix[15]
  if clip.z < 0.2:
    raise newException(Exception, "WTS")

  clip.x = pos.x * matrix[0] + pos.y * matrix[1] + pos.z * matrix[2] + matrix[3]
  clip.y = pos.x * matrix[4] + pos.y * matrix[5] + pos.z * matrix[6] + matrix[7]

  ndc.x = clip.x / clip.z
  ndc.y = clip.y / clip.z

  result.x = (a.width / 2 * ndc.x) + (ndc.x + a.width / 2)
  result.y = (a.height / 2 * ndc.y) + (ndc.y + a.height / 2)

proc help() {.exportpy.} =
  echo cheatsheet