#pragma once

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/wrapped.hpp>
#include <godot_cpp/core/binder_common.hpp>
#include <godot_cpp/variant/string.hpp>

namespace godot {

class HeroismWarNode : public Node3D {
    GDCLASS(HeroismWarNode, Node3D)

protected:
    static void _bind_methods();

public:
    HeroismWarNode();
    ~HeroismWarNode();

    void _ready() override;
    void _process(double delta) override;

    void start_match();
    void set_player_name(const String &name);
    String get_player_name() const;
    void register_shot(const String &weapon_type, float damage);
    int get_match_score() const;

private:
    String player_name = "Ranger";
    int match_score = 0;
};

} // namespace godot
