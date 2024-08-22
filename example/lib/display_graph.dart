/*
 * Copyright 2024 Canardoux.
 *
 * This file is part of the τ Project.
 *
 * τ (Tau) is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * τ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/*
 *
 * This is a very simple example for Tau beginners,
 * that show how to playback a file.
 *
 * This example is really basic.
 *
 */

import 'package:flutter/material.dart';

class DisplayGraph extends StatelessWidget {
  final String? graphDir;
  final String? graphImage;
  final String? mod;
  //const DisplayGraph({super.key});

  /* ctor */ const DisplayGraph(this.mod, this.graphDir, this.graphImage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(graphImage!),
      ),
      body: Center(
        child: Container(
          color: Colors.blue,
          child: Image.asset(
            "lib/${mod}Ex/${graphDir!}/${mod}Ex_${graphImage!}_graph.png",
          ),
        ),
      ),
    );
  }
}
