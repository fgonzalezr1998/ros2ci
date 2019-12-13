#!/bin/bash
# Copyright 2019 Mikael Arguedas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

function install_dependencies() {
# install dependencies
apt-get -qq update && rosdep update && rosdep install -y \
  --from-paths src \
  --ignore-src \
  --rosdistro $ROS_DISTRO
}

function build_workspace() {
colcon build \
    --symlink-install \
    --cmake-args -DSECURITY=ON --no-warn-unused-cli
}

function test_workspace() {
'''
colcon test \
    --executor sequential \
    --event-handlers console_direct+

    /opt/ros/$ROS_DISTRO/bin/ament_cppcheck --language=c++ \
    --xunit-file ./build/mocap_camera_composer/test_results/mocap_camera_composer/cppcheck.xunit.xml \
    --include_dirs ./src/MOCAP4ROS2/vicon2/mocap_camera_composer/include

    /usr/bin/python3 "-u" "/opt/ros/dashing/share/ament_cmake_test/cmake/run_test.py" \
    "/home/david/ros2/mocap_ws/build/mocap_camera_composer/test_results/mocap_camera_composer/cppcheck.xunit.xml" \
    "--package-name" "mocap_camera_composer" "--output-file" \
    "/home/david/ros2/mocap_ws/build/mocap_camera_composer/ament_cppcheck/cppcheck.txt" \
    "--command" "/opt/ros/dashing/bin/ament_cppcheck" "--xunit-file" \
    "/home/david/ros2/mocap_ws/build/mocap_camera_composer/test_results/mocap_camera_composer/cppcheck.xunit.xml" \
    "--include_dirs" "/home/david/git/MOCAP4ROS2/vicon2/mocap_camera_composer/include"
    '''
    /usr/bin/python3 "-u" "/opt/ros/dashing/share/ament_cmake_test/cmake/run_test.py" \
    "/opt/ros2_overlay_ws/build/mocap_camera_composer/test_results/mocap_camera_composer/cppcheck.xunit.xml" \
    "--package-name" "mocap_camera_composer" "--output-file" "/opt/ros2_overlay_ws/build/mocap_camera_composer/ament_cppcheck/cppcheck.txt" \
    "--command" "/opt/ros/dashing/bin/ament_cppcheck" "--xunit-file" \
    "/opt/ros2_overlay_ws/build/mocap_camera_composer/test_results/mocap_camera_composer/cppcheck.xunit.xml" \
    "--include_dirs" "/opt/ros2_overlay_ws/src/IntelligentRoboticsLabs/MOCAP4ROS2/vicon2/mocap_camera_composer/include" \
    "--language" "c++"
colcon test-result
}

install_dependencies

# source ROS_DISTRO in case newly installed packages modified environment
source /opt/ros/$ROS_DISTRO/setup.bash

build_workspace
test_workspace
