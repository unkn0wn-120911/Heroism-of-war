#include "heroism_war_node.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/variant/string.hpp>

namespace godot {

HeroismWarNode::HeroismWarNode() {
}

HeroismWarNode::~HeroismWarNode() {
}

void HeroismWarNode::_bind_methods() {
    ClassDB::bind_method(D_METHOD("start_match"), &HeroismWarNode::start_match);
    ClassDB::bind_method(D_METHOD("set_player_name", "name"), &HeroismWarNode::set_player_name);
    ClassDB::bind_method(D_METHOD("get_player_name"), &HeroismWarNode::get_player_name);
    ClassDB::bind_method(D_METHOD("register_shot", "weapon_type", "damage"), &HeroismWarNode::register_shot);
    ClassDB::bind_method(D_METHOD("get_match_score"), &HeroismWarNode::get_match_score);
}

void HeroismWarNode::_ready() {
    UtilityFunctions::print("HeroismWarNode ready. Match system online.");
}

void HeroismWarNode::_process(double delta) {
    (void)delta;
}

void HeroismWarNode::start_match() {
    match_score = 0;
    UtilityFunctions::print("Match started for player: " + player_name);
}

void HeroismWarNode::set_player_name(const String &name) {
    player_name = name;
}

String HeroismWarNode::get_player_name() const {
    return player_name;
}

void HeroismWarNode::register_shot(const String &weapon_type, float damage) {
    UtilityFunctions::print("Shot fired with " + weapon_type + " for " + String::num_real(damage, 2) + " damage.");
    match_score += static_cast<int>(damage);
}

int HeroismWarNode::get_match_score() const {
    return match_score;
}

} // namespace godot
