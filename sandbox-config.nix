{ lib, config, pkgs, ... }:
{
  systemd.slices.system.sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  systemd.slices.user.sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15";
  };
  # User: abright (UID: 1013)
  systemd.slices."user-1013".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: anadamal (UID: 1022)
  systemd.slices."user-1022".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: apple (UID: 1000)
  systemd.slices."user-1000".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: c24ma (UID: 1001)
  systemd.slices."user-1001".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: cjian (UID: 1006)
  systemd.slices."user-1006".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: d62liu (UID: 1023)
  systemd.slices."user-1023".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: e5jin (UID: 1016)
  systemd.slices."user-1016".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: fa2bhuiy (UID: 1020)
  systemd.slices."user-1020".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: gaga (UID: 1004)
  systemd.slices."user-1004".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: j2655li (UID: 1003)
  systemd.slices."user-1003".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: kushal (UID: 1018)
  systemd.slices."user-1018".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: m5jung (UID: 1015)
  systemd.slices."user-1015".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: mr2shah (UID: 1007)
  systemd.slices."user-1007".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: mvcalabr (UID: 1017)
  systemd.slices."user-1017".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: n9jin (UID: 1008)
  systemd.slices."user-1008".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: rtanweer (UID: 1019)
  systemd.slices."user-1019".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: s2sivath (UID: 1021)
  systemd.slices."user-1021".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: saurin (UID: 1012)
  systemd.slices."user-1012".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: y3536zha (UID: 1009)
  systemd.slices."user-1009".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: y472zhan (UID: 1014)
  systemd.slices."user-1014".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: yizhou (UID: 1002)
  systemd.slices."user-1002".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: z33ge (UID: 1010)
  systemd.slices."user-1010".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  # User: z358zhao (UID: 1011)
  systemd.slices."user-1011".sliceConfig = {
    AllowedCPUs = "0,1,2,3,4,5,6,8,9,10,11,12,13,14";
  };
  systemd.slices.benchmark.sliceConfig = {
    AllowedCPUs = "7,15";
  };
}
