"""Replace the single embedded PNG image inside a .glb with new bytes.

Pure struct/json, no bpy, no external glTF library. Only safe when the
image's bufferView is the LAST bufferView in the buffer (checked, not
assumed) -- then swapping it for a different-sized PNG only requires
rewriting that one bufferView's byteLength and the buffer's byteLength,
nothing else shifts.
"""
import json
import struct
import sys


def load_glb(path):
    with open(path, "rb") as f:
        magic, ver, length = struct.unpack("<III", f.read(12))
        assert magic == 0x46546C67, "not a glb"
        json_data = None
        bin_data = None
        while f.tell() < length:
            clen, ctype = struct.unpack("<II", f.read(8))
            data = f.read(clen)
            if ctype == 0x4E4F534A:
                json_data = data
            elif ctype == 0x004E4942:
                bin_data = data
    return json.loads(json_data), bytearray(bin_data)


def replace_image(in_path, out_path, image_index, new_png_bytes):
    j, bin_data = load_glb(in_path)
    img = j["images"][image_index]
    bv_idx = img["bufferView"]
    bv = j["bufferViews"][bv_idx]
    assert bv["buffer"] == 0

    end_of_bv = bv["byteOffset"] + bv["byteLength"]
    buf_len = j["buffers"][0]["byteLength"]
    assert end_of_bv >= buf_len - 1, (
        "image bufferView is not last in the buffer -- this patcher only "
        "handles the last-bufferView case safely"
    )
    # Confirm no OTHER bufferView starts at/after this one's offset.
    for i, other in enumerate(j["bufferViews"]):
        if i != bv_idx:
            assert other["byteOffset"] < bv["byteOffset"], (
                "another bufferView (%d) sits after the image -- unsafe" % i
            )

    new_bin = bytes(bin_data[: bv["byteOffset"]]) + new_png_bytes
    bv["byteLength"] = len(new_png_bytes)
    j["buffers"][0]["byteLength"] = bv["byteOffset"] + len(new_png_bytes)

    json_bytes = json.dumps(j, separators=(",", ":")).encode("utf-8")
    while len(json_bytes) % 4 != 0:
        json_bytes += b" "
    while len(new_bin) % 4 != 0:
        new_bin += b"\x00"

    total_len = 12 + 8 + len(json_bytes) + 8 + len(new_bin)
    with open(out_path, "wb") as f:
        f.write(struct.pack("<III", 0x46546C67, 2, total_len))
        f.write(struct.pack("<II", len(json_bytes), 0x4E4F534A))
        f.write(json_bytes)
        f.write(struct.pack("<II", len(new_bin), 0x004E4942))
        f.write(new_bin)


def extract_image(path, image_index):
    j, bin_data = load_glb(path)
    img = j["images"][image_index]
    bv = j["bufferViews"][img["bufferView"]]
    return bytes(bin_data[bv["byteOffset"]: bv["byteOffset"] + bv["byteLength"]])


if __name__ == "__main__":
    # quick self-test: round-trip the image out and back in unchanged
    src = sys.argv[1]
    data = extract_image(src, 0)
    replace_image(src, "/tmp/roundtrip_test.glb", 0, data)
    j2, _ = load_glb("/tmp/roundtrip_test.glb")
    print("roundtrip OK, buffer byteLength", j2["buffers"][0]["byteLength"])
