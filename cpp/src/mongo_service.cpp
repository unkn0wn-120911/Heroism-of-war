#include "mongo_service.h"

#if __has_include(<mongocxx/client.hpp>) && __has_include(<mongocxx/instance.hpp>)
#include <bsoncxx/json.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/options/client.hpp>
#include <mongocxx/uri.hpp>

namespace heroism_war {

static mongocxx::instance instance{};
static std::unique_ptr<mongocxx::client> client;

bool MongoService::connect(const std::string &uri) {
    try {
        client = std::make_unique<mongocxx::client>(mongocxx::uri{uri});
        return client != nullptr;
    } catch (const std::exception &) {
        return false;
    }
}

void MongoService::disconnect() {
    client.reset();
}

bool MongoService::is_connected() {
    return client != nullptr;
}

void MongoService::save_player_profile(const std::string &player_id, const std::string &payload) {
    if (!client) {
        return;
    }

    auto db = (*client)["heroism_of_war"];
    auto collection = db["players"];
    auto doc = bsoncxx::from_json(payload);
    collection.insert_one(doc.view());
    (void)player_id;
}

} // namespace heroism_war
#else
namespace heroism_war {

bool MongoService::connect(const std::string &) { return false; }
void MongoService::disconnect() {}
bool MongoService::is_connected() { return false; }
void MongoService::save_player_profile(const std::string &, const std::string &) {}

} // namespace heroism_war
#endif
