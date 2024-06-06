import json

if __name__ == "__main__":

    config = {
        "base_infra": "",
        "multi_user": False,
        "provider_version": "",
        "health_check": "",
        "cluster_config": {
          "architecture": "amd64",
          "controller_GVNIC": False,
          "controller_image": "latest",
          "controller_tier_1": False,
          "export_fs_type": "xfs",
          "image_disk_count": "1",
          "image_disk_name": "noaa-apps-09-image",
          "image_disk_size_gb": "250",
          "management_shape": "c2-standard-8",
          "migrate_on_maintenance": True,
          "partition_config": list(),
          "region": "us-central1",
          "zone": "us-central1-c",
          "slurm_suspend_time": "",
          "slurm_resume_timeout": "",
          "slurm_suspend_timeout": "",
          "slurm_return_to_service": "",
          "disks": []
        },
      "storages": [],
      "c": "amd64",
      "l": False,
      "u": False
    }

    base_config = {
        "max_node_num": 8,
        "os": "centos",
        "zone": "us-central1-c",
        "architecture": "amd64",
        "default": "NO",
        "elastic_image": "latest",
        "gvnic": False,
        "tier_1": False,
        "migrate_on_maintenance": False,
    }


    for is_spot in [False, True]:
        for memory in [40, 80]:
            for n_gpus in [1, 4, 8]:

                name = f"{n_gpus}-a100-{memory}gb"
                if is_spot:
                    name += "-spot"

                memname = "high" if memory == 40 else "ultra"

                my_config = {
                    "name": name,
                    "instance_type": f"a2-{memname}gpu-{n_gpus}g",
                    "enable_spot": is_spot,
                    **base_config,
                }

                # make first entry the default
                if len(config["cluster_config"]["partition_config"]) == 0:
                    my_config["default"] = "YES"

                config["cluster_config"]["partition_config"].append(my_config)

    with open(f"gcp_gpus.json", "w") as f:
        json.dump(config, f, indent=2)
