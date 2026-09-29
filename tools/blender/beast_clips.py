"""Keyframes for the rigged beasts' one-shot clips, shared by ai_beast.py (a
fresh build) and ai_beast_clip.py (adding a clip to a beast already built).

Each clip is [(frame, {bone: (x, y, z) degrees})] at 30 fps, rotation only.
"""


def death(legs):
    """The killing blow lands, the legs go, it rolls onto its far side and stays.

    Root +Y rolls the body toward -X, away from the climb route (+X, the camera
    side), so it falls away from the hunters and shows its belly and legs.
    The last frame is the body down: the game holds it, never loops back.
    """
    near_f = "fl" if "fl" in legs else "fr"
    far_f = "fr" if near_f == "fl" else "fl"
    near_h = "hl" if "hl" in legs else "hr"
    far_h = "hr" if near_h == "hl" else "hl"
    buckle = {near_f + "_upper": (-28, 0, 0), near_f + "_lower": (40, 0, 0),
              far_f + "_upper": (-30, 0, 0), far_f + "_lower": (44, 0, 0)}
    splay = {near_f + "_upper": (-20, 0, 25), near_f + "_lower": (30, 0, 0),
             far_f + "_upper": (-10, 0, -10), far_f + "_lower": (20, 0, 0),
             near_h + "_upper": (15, 0, 30), near_h + "_lower": (-20, 0, 0),
             far_h + "_upper": (8, 0, -8)}
    return [
        (0, {}),
        # the recoil of the last hit, bigger than "hit"
        (5, {"neck": (-26, 0, -12), "head": (-22, 0, -14), "chest": (-6, 0, 0),
             "tail1": (16, 0, 10), "tail2": (12, 0, 12)}),
        # front legs go, head drops
        (14, dict(buckle, **{"root": (0, 8, 0), "neck": (14, 0, -6), "head": (10, 0, -8),
                              "chest": (6, 0, 0), "tail1": (6, 0, 4)})),
        # over onto its side
        (32, dict(splay, **{"root": (0, 80, 0), "neck": (20, 0, 10), "head": (12, 0, 14),
                             "tail1": (-6, 0, -10), "tail2": (-4, 0, -12)})),
        # the bounce
        (37, dict(splay, **{"root": (0, 72, 0), "neck": (14, 0, 8), "head": (8, 0, 10),
                             "tail1": (-4, 0, -8)})),
        # still
        (46, dict(splay, **{"root": (0, 76, 0), "neck": (22, 0, 12), "head": (16, 0, 16),
                             "tail1": (-8, 0, -14), "tail2": (-6, 0, -16), "tail3": (-4, 0, -10)})),
    ]
