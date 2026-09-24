#pragma once

#include <string>

namespace heroism_war {

class MongoService {
public:
    MongoService() = default;
    ~MongoService() = default;

    static bool connect(const std::string &uri);
    static void disconnect();
    static bool is_connected();
    static void save_player_profile(const std::string &player_id, const std::string &payload);
};

} // namespace heroism_war
