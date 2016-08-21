//
//  PusherGlobalChannel.swift
//  PusherSwift
//
//  Created by Hamilton Chapman on 01/04/2016.
//
//

public class PusherChannels {
    public var channels = [String: PusherChannel]()

    /**
        Create a new PusherChannel, which is returned, and add it to the PusherChannels list
        of channels

        - parameter channelName:     The name of the channel to create
        - parameter connection:      The connection associated with the channel being created
        - parameter onMemberAdded:   A function that will be called with information about the
                                     member who has just joined the presence channel
        - parameter onMemberRemoved: A function that will be called with information about the
                                     member who has just left the presence channel

        - returns: A new PusherChannel instance
    */
    internal func add(
        channelName: String,
        connection: PusherConnection,
        onMemberAdded: ((PresenceChannelMember) -> ())? = nil,
        onMemberRemoved: ((PresenceChannelMember) -> ())? = nil) -> PusherChannel {
            if let channel = self.channels[channelName] {
                return channel
            } else {
                var newChannel: PusherChannel
                if PusherChannelType.isPresenceChannel(name: channelName) {
                    newChannel = PresencePusherChannel(
                        name: channelName,
                        connection: connection,
                        onMemberAdded: onMemberAdded,
                        onMemberRemoved: onMemberRemoved
                    )
                } else {
                    newChannel = PusherChannel(name: channelName, connection: connection)
                }
                self.channels[channelName] = newChannel
                return newChannel
            }
    }

    /**
        Remove the PusherChannel with the given channelName from the channels list

        - parameter channelName: The name of the channel to remove
    */
    internal func remove(channelName: String) {
        self.channels.removeValueForKey(channelName)
    }

    /**
        Return the PusherChannel with the given channelName from the channels list, if it exists

        - parameter channelName: The name of the channel to return

        - returns: A PusherChannel instance, if a channel with the given name existed, otherwise nil
    */
    internal func find(channelName: String) -> PusherChannel? {
        return self.channels[channelName]
    }
}