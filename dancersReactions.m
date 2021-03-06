%% Initialization

% these are the properties of the registration system
eventProps = {'number of places',...
    'registering schedule',...
    'roled',...
    'partnered preferred',...
    'price-pattern',...
};

totalLeadersRejected = 0;
totalFollowersRejected = 0;

% make an initial population of dancers
leadFollowRatio = 0.8;
initialDancerPopulation = 250;
initialLeaderPopulation = round(initialDancerPopulation/2*leadFollowRatio);
initialFollowerPopulation = round(initialDancerPopulation/2/leadFollowRatio);

leaders = createNewDancers(initialLeaderPopulation);
followers = createNewDancers(initialFollowerPopulation);

% what part of the dancers is partnered?
partneredRatio = 0.5;
partneredDancers = partneredRatio*min(initialLeaderPopulation,initialFollowerPopulation);
leaders(1:partneredDancers, 12) = 1:partneredDancers;
followers(1:partneredDancers, 12) = 1:partneredDancers; % now the initial population is partially partnered
% partnered dancers get an advantage, as their planned property is the
% maximum of the two properties
partneredLeaders = leaders(:, 12) > 0;
if sum(partneredLeaders) > 0
    for partneredLeadersIndex = find(partneredLeaders)'
        leaders(partneredLeadersIndex, 1) = max([leaders(partneredLeadersIndex, 1), ...
            followers(leaders(partneredLeadersIndex, 12), 1)]);
        followers(leaders(partneredLeadersIndex, 12), 1) = leaders(partneredLeadersIndex, 1);
    end
end

totalSceneHappiness = sum([leaders(:, 11); ...
    followers(:, 11)]);
    
dancerSummaryFigure = figure;
subplot(4,1,1)
hold on
title('Dancers'' mean happiness')
subplot(4,1,2)
hold on
title('Dancers'' population')
subplot(4,1,3)
hold on
title('Dancers'' mean planning skills')
subplot(4,1,4)
hold on
title('Amount of partnered dancers')

for i = 1:100
    %% Update the scene population
    % New dancers will join the scene regularly, based on the total active scene happiness
    newLeaderPopulation = totalSceneHappiness/1000;
    newFollowerPopulation = newLeaderPopulation/leadFollowRatio;
    leaders = [leaders; createNewDancers(round(newLeaderPopulation))];
    followers = [followers; createNewDancers(round(newFollowerPopulation))];
    % partner the new dancers up
    if newLeaderPopulation >= 0.5 && newFollowerPopulation >= 0.5
        leaders(end-round(newLeaderPopulation*partneredRatio)+1:end, 12) = ...
            length(followers)-round(newLeaderPopulation*partneredRatio)+1:length(followers);
        followers(leaders(end-round(newLeaderPopulation*partneredRatio)+1:end, 12), 12) = ...
            length(leaders)-round(newLeaderPopulation*partneredRatio)+1:length(leaders);
    end
    
    % Partnered dancers will have their average happiness as their current score
    % Their planned property is the maximum of the two properties
    partneredLeaders = leaders(:, 12) > 0; % this currently also updates the already inactive dancers every round. Here, some time could be gained if needed
    if sum(partneredLeaders) > 0
        for partneredLeadersIndex = find(partneredLeaders)'
            leaders(partneredLeadersIndex, 11) = mean([leaders(partneredLeadersIndex, 11), ...
                followers(leaders(partneredLeadersIndex, 12), 11)]);
            followers(leaders(partneredLeadersIndex, 12), 11) = leaders(partneredLeadersIndex, 11);
            leaders(partneredLeadersIndex, 1) = max([leaders(partneredLeadersIndex, 1), ...
                followers(leaders(partneredLeadersIndex, 12), 1)]);
            followers(leaders(partneredLeadersIndex, 12), 1) = leaders(partneredLeadersIndex, 1);
        end
    end
    
    % Dancers with negative happiness are no longer part of the scene
    leadersDancingIndices = leaders(:, 11) > 0;
    followersDancingIndices = followers(:, 11) > 0;

    currentLeaderPopulation = sum(leadersDancingIndices);
    currentFollowerPopulation = sum(followersDancingIndices);

    totalSceneHappiness = sum([leaders(leadersDancingIndices, 11); ...
        followers(followersDancingIndices, 11)]);

    % Display the dancers mean happiness values
    subplot(4,1,1)
    plot(i, mean(leaders(leadersDancingIndices,11)), 'ro')
    plot(i, mean(followers(followersDancingIndices,11)), 'bo')
    subplot(4,1,2)
    plot(i, currentLeaderPopulation, 'ro')
    plot(i, currentFollowerPopulation, 'bo')
    subplot(4,1,3)
    plot(i, mean(leaders(leadersDancingIndices,1)), 'ro')
    plot(i, mean(followers(followersDancingIndices,1)), 'bo')
    subplot(4,1,4)
    plot(i, sum(partneredLeaders)/length(leaders), 'ro')
    plot(i, sum(partneredLeaders)/length(followers), 'bo')

    %% Start an event registration and check who is getting in
    % set the properties of an event
    thisEventProps = [100,1,1,1,1];

    % not all will want to participate (currently about half)
    applicantsLeadersIndices = logical(randi(2,1,length(leaders))' - 1);
    applicantsFollowersIndices = logical(randi(2,1,length(followers))' - 1);
    % Make sure that partners always register together. This depends on
    % x-oring the above random choice, which results again in half of them
    % registering. But this only works if the random choice above also
    % chooses half of the population.
    if sum(partneredLeaders) > 0
        for partneredLeadersIndex = find(partneredLeaders)'
            applicantsLeadersIndices(partneredLeadersIndex) = ...
                xor(applicantsLeadersIndices(partneredLeadersIndex), applicantsFollowersIndices(leaders(partneredLeadersIndex, 12)));
            applicantsFollowersIndices(leaders(partneredLeadersIndex, 12)) = applicantsLeadersIndices(partneredLeadersIndex);
        end
    end
    applicantsLeadersIndices = find(applicantsLeadersIndices & leadersDancingIndices);
    thisEventLeadersIndices = leaders(applicantsLeadersIndices, :);
    applicantsFollowersIndices = find(applicantsFollowersIndices & followersDancingIndices);
    thisEventFollowersIndices = followers(applicantsFollowersIndices, :);
    
    % sort the population by their planned-attributed, modified by their motivation
    % the more planned and the more happy/motivated they are, the earlier will
    % the register
    [~, sortedApplicantsLeadersIndices] = sort(thisEventLeadersIndices(:, 1) + thisEventLeadersIndices(:, 11), 1, 'descend');
    thisEventLeadersIndices = applicantsLeadersIndices(sortedApplicantsLeadersIndices);
    [~, sortedApplicantsFollowersIndices] = sort(thisEventFollowersIndices(:, 1) + thisEventFollowersIndices(:, 11), 1, 'descend');
    thisEventFollowersIndices = applicantsFollowersIndices(sortedApplicantsFollowersIndices);

    switch thisEventProps(3)
        case 0
            % this is an un-roled event

        case 1
            % this is a roled event

            % find who made it into the workshop
            thisEventLeadersIndices = thisEventLeadersIndices(1:min(length(thisEventLeadersIndices),thisEventProps(1)/2));
            thisEventFollowersIndices = thisEventFollowersIndices(1:min(length(thisEventFollowersIndices),length(thisEventLeadersIndices)),:);
            thisEventLeadersIndices = thisEventLeadersIndices(1:min(length(thisEventLeadersIndices),length(thisEventFollowersIndices)));

            % Make sure that partnered dancers only participate if they get
            % in together
            if sum(partneredLeaders) > 0
                for partneredLeadersIndex = find(partneredLeaders)'
                    applicantsLeadersIndices(partneredLeadersIndex) = ...
                        xor(applicantsLeadersIndices(partneredLeadersIndex), applicantsFollowersIndices(leaders(partneredLeadersIndex, 12)));
                    applicantsFollowersIndices(leaders(partneredLeadersIndex, 12)) = applicantsLeadersIndices(partneredLeadersIndex);
                end
            end
            
        case 2
            % this is a partnered event
    end

    % keep a total of how many got rejected at all events
    totalLeadersRejected = totalLeadersRejected + length(applicantsLeadersIndices) - length(thisEventLeadersIndices);
    totalFollowersRejected = totalFollowersRejected + length(applicantsFollowersIndices) - length(thisEventFollowersIndices);

    % mark the participation for each dancer
    leaders(thisEventLeadersIndices, 13) = leaders(thisEventLeadersIndices, 13) + 1;
    followers(thisEventFollowersIndices, 13) = followers(thisEventFollowersIndices, 13) + 1;

    % the happiness/motivation of everybody goes down with time
    leaders(:, 11) = leaders(:, 11) - 0.05;
    followers(:, 11) = followers(:, 11) - 0.05;

    % update the happiness/motivation of the rejected, depending on their frustration tolerance
    % (it seems as if we degraded all; but we will update the actual participants in the next step)
    leaders(applicantsLeadersIndices, 11) = leaders(applicantsLeadersIndices, 11) - 1./leaders(applicantsLeadersIndices, 10);
    followers(applicantsFollowersIndices, 11) = followers(applicantsFollowersIndices, 11) - 1./followers(applicantsFollowersIndices, 10);

    % update the happiness/motivation of the participants
    leaders(thisEventLeadersIndices, 11) = leaders(thisEventLeadersIndices, 11) + 1;
    followers(thisEventFollowersIndices, 11) = followers(thisEventFollowersIndices, 11) + 1;

end

function newDancers = createNewDancers(numberOfNewDancers)
% these are the different properties that make up the dancers stance on
% different topics. 0 is "medium", negative means no, positive means yes
dancerProps = {'planned',... 1
    'price-sensitive',... 2
    'roled',... 3
    'partnered',... 4
    'outgoing',... 5
    'equalitarian',... 6
    'feminist/masculinist',... 7
    'home-scene bound',... 8
    'returning',... 9
    'frustration-tolerant',... 10
    'happy/motivated',... 11
    'preferred partner',... 12
    'visited workshops'... 13
};

newDancers = [randn(numberOfNewDancers, length(dancerProps) - 4), ... % the personal attributes are normally distributed
    abs(randn(numberOfNewDancers, 1)*0.1 + 1), ... % the frustration tolerance is a multiplicator and can only be positive
    randn(numberOfNewDancers, 1) + 10, ... % everybody starts out quite happy
    zeros(numberOfNewDancers, 1), ... % at initialisation, nobody is partnered.
    zeros(numberOfNewDancers, 1)]; % nobody has participated at an event yet.

return
end